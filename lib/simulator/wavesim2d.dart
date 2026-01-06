import 'dart:js_interop';
import 'dart:typed_data' as types;

import 'package:web/web.dart';

import '../webgpu/index.dart';
import 'wavesim_render.dart';

/// 2D longitudinal wave simulator
class Wavesim2d {
  /// The size of the simulation grid
  final Size gridSize;

  /// The size of the grid that is visible
  late final Size visibleSize;

  /// Energy transfer coefficient in the range (0, 1].
  final double c;

  /// The maximum allowed wavelength
  ///
  /// This doesn't prevent waves with such wavelengths or longer from forming,
  /// however these waves wont be absorbed by the damping boundary and will end
  /// up being reflected back towards the visible grid.
  final double maxWavelength;

  /// GPU computation block size
  final int blockSize;

  /// Size of the damping boundary
  final int dampRegion;

  /// The GPU device
  final GPUDevice device;

  /// Shader module containing the shader that computes the simulation state.
  final GPUShaderModule shader;

  /// Renderer to use for rendering the simulation
  final WavesimRender render;

  /// The current simulation time
  int get time => _time;

  Wavesim2d({
    required this.device,
    required this.shader,
    required this.render,
    required this.gridSize,
    required this.c,
    this.maxWavelength = 1,
    this.blockSize = 8,
    this.dampRegion = 30,
  }) {
    visibleSize = _calcVisibleSize(
        size: gridSize,
        maxWavelength: maxWavelength,
        dampRegion: dampRegion
    );

    _bindGroupLayout = device.createBindGroupLayout(
      BindGroupLayoutDescriptor(
        entries: <BindEntry>[
          BindEntry(
            binding: 0,
            visibility: $GPUShaderStage.COMPUTE,
            buffer: BufferLayout(
              type: 'uniform'
            )
          ),
          BindEntry(
              binding: 1,
              visibility: $GPUShaderStage.COMPUTE,
              buffer: BufferLayout(
                  type: 'uniform'
              )
          ),
          BindEntry(
              binding: 2,
              visibility: $GPUShaderStage.COMPUTE,
              buffer: BufferLayout(
                  type: 'read-only-storage'
              )
          ),
          BindEntry(
              binding: 3,
              visibility: $GPUShaderStage.COMPUTE,
              buffer: BufferLayout(
                  type: 'read-only-storage'
              )
          ),
          BindEntry(
              binding: 4,
              visibility: $GPUShaderStage.COMPUTE,
              buffer: BufferLayout(
                  type: 'storage'
              )
          ),
          BindEntry(
              binding: 5,
              visibility: $GPUShaderStage.COMPUTE,
              buffer: BufferLayout(
                  type: 'storage'
              )
          ),
          BindEntry(
              binding: 6,
              visibility: $GPUShaderStage.COMPUTE,
              buffer: BufferLayout(
                  type: 'storage'
              )
          ),
        ].toJS
      )
    );

    _initCompute();
  }

  /// Update the state of the simulation by a single step.
  Future<void> update() async {
    _time++;

    final bindGroup = _currentBuffer > 0 ? _bindGroup2 : _bindGroup1;
    final encoder = device.createCommandEncoder();

    encoder.clearBuffer(_heatmap);
    encoder.clearBuffer(_maxHeat);

    final compute = encoder.beginComputePass();

    compute.setPipeline(_computePipeline);
    compute.setBindGroup(0, bindGroup);
    
    compute.dispatchWorkgroups(
        (gridSize.width / blockSize).ceil(),
        (gridSize.height / blockSize).ceil()
    );

    compute.end();

    render.render(
        encoder: encoder,
        data: _currentBuffer > 0 ? _u1 : _u2
    );

    device.queue.submit([encoder.finish()].toJS);
    await device.queue.onSubmittedWorkDone().toDart;

    _currentBuffer ^= 1;
  }

  // Private

  /// Compute shader binding layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// Computational pipeline
  late final GPUComputePipeline _computePipeline;

  /// Buffer holding the size of the grid
  late final GPUBuffer _sizeBuffer;

  /// Buffer holding the simulation parameters (c).
  late final GPUBuffer _paramsBuffer;

  /// First simulation state buffer
  late final GPUBuffer _u1;

  /// Second simulation state buffer
  late final GPUBuffer _u2;

  /// Buffer holding the damping coefficients of the grid
  late final GPUBuffer _damping;

  /// Buffer into which the heat map is written
  late final GPUBuffer _heatmap;

  /// Buffer into which the maximum heat is written
  late final GPUBuffer _maxHeat;

  /// First bind group.
  ///
  /// This binds [_u1] as the current state buffer and [_u2] as the previous
  /// and next state buffer.
  late final GPUBindGroup _bindGroup1;

  /// Second bind group.
  ///
  /// This binds [_u2] as the current state buffer and [_u1] as the previous
  /// and next state buffer.
  late final GPUBindGroup _bindGroup2;

  /// Current simulation time
  var _time = 0;

  /// The currently bound simulation state buffer.
  var _currentBuffer = 0;

  static Size _calcVisibleSize({
    required Size size,
    required double maxWavelength,
    required int dampRegion
  }) => Size(
      width: (size.width + maxWavelength * dampRegion).ceil(),
      height: (size.height + maxWavelength * dampRegion).ceil()
  );

  void _initCompute() {
    _computePipeline = device.createComputePipeline(
      ComputePipelineLayout(
        layout: device.createPipelineLayout(
            PipelineLayoutDescriptor(
              bindGroupLayouts: [_bindGroupLayout].toJS
            )
        ),
        compute: ComputeDescriptor(
          module: shader,
          constants: {
            'blockSize': blockSize
          }.jsify()
        )
      )
    );

    _sizeBuffer = _makeUInt32Buffer(
        types.Uint32List.fromList([
          gridSize.width,
          gridSize.height
        ])
    );

    _paramsBuffer = _makeFloat32Buffer(
      types.Float32List.fromList([c])
    );

    _u1 = _makePosBuffer();
    _u2 = _makePosBuffer();

    _initDamping();
    _initHeatmap();

    _bindGroup1 = _makeBindGroup(_u1, _u2);
    _bindGroup2 = _makeBindGroup(_u2, _u1);

    _time = 0;
    _currentBuffer = 0;
  }

  /// Create a buffer for holding the simulation state.
  GPUBuffer _makePosBuffer() {
    final nCells = gridSize.area;
    final nElems = nCells * 2;

    return _makeFloat32Buffer(types.Float32List(nElems),
      usage: $GPUBufferUsage.STORAGE |
        $GPUBufferUsage.VERTEX |
        $GPUBufferUsage.COPY_DST |
        $GPUBufferUsage.COPY_SRC,
    );
  }

  /// Initialize the buffer holding the damping coefficients.
  void _initDamping() {
    final data = types.Float32List(gridSize.area);

    // Assuming square grid
    final offset = (gridSize.width - visibleSize.width) / 2;

    for (var i = 0; i < offset; i++) {
      final damp = 1 - (0.01 / maxWavelength) * (offset - i) / maxWavelength;

      final t = i * gridSize.width;
      final b = (gridSize.height - i - 1) * gridSize.width;
      final r = gridSize.width - i - 1;

      for (var j = i; j < gridSize.width; j++) {
        data[t+j] = damp;
        data[b+j] = damp;

        data[j * gridSize.width + i] = damp;
        data[j * gridSize.width + r] = damp;
      }
    }

     _damping = _makeFloat32Buffer(data,
        usage: $GPUBufferUsage.STORAGE |
            $GPUBufferUsage.UNIFORM,
     );
  }

  /// Create the buffers for holding the heat map and maximum heat
  void _initHeatmap() {
    _heatmap = _makeUInt32Buffer(
        types.Uint32List(gridSize.area),
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.VERTEX |
          $GPUBufferUsage.COPY_DST
    );
    
    _maxHeat = _makeUInt32Buffer(
        types.Uint32List(1),
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.VERTEX |
          $GPUBufferUsage.COPY_DST
    );
  }

  /// Create a uint32 buffer initialized with [data].
  GPUBuffer _makeUInt32Buffer(types.Uint32List data, {
    int usage = $GPUBufferUsage.STORAGE |
      $GPUBufferUsage.UNIFORM |
      $GPUBufferUsage.COPY_DST |
      $GPUBufferUsage.VERTEX
  }) {
    final buffer = device.createBuffer(
        BufferDescriptor(
            size: data.lengthInBytes,
            usage: usage,
            mappedAtCreation: true
        )
    );

    final view = types.Uint32List.view(buffer.getMappedRange().toDart);
    view.setAll(0, data);

    buffer.unmap();
    return buffer;
  }

  /// Create a float32 buffer initialized with [data].
  GPUBuffer _makeFloat32Buffer(types.Float32List data, {
    int usage = $GPUBufferUsage.STORAGE |
      $GPUBufferUsage.UNIFORM |
      $GPUBufferUsage.COPY_DST
  }) {
    final buffer = device.createBuffer(
        BufferDescriptor(
            size: data.lengthInBytes,
            usage: usage,
            mappedAtCreation: true
        )
    );

    final view = types.Float32List.view(buffer.getMappedRange().toDart);
    view.setAll(0, data);

    buffer.unmap();
    return buffer;
  }

  /// Create a bind group.
  ///
  /// [u1] is bound as the current state buffer.
  /// [u2] is bound as the previous and next state buffer.
  GPUBindGroup _makeBindGroup(GPUBuffer u1, GPUBuffer u2) =>
      device.createBindGroup(
        BindGroupDescriptor(
            layout: _bindGroupLayout,
            entries: [
              BindGroupEntry(
                  binding: 0,
                  resource: GPUBufferBinding(
                    buffer: _sizeBuffer
                  )
              ),
              BindGroupEntry(
                  binding: 1,
                  resource: GPUBufferBinding(
                      buffer: _paramsBuffer
                  )
              ),
              BindGroupEntry(
                  binding: 2,
                  resource: GPUBufferBinding(
                      buffer: _damping
                  )
              ),
              BindGroupEntry(
                  binding: 3,
                  resource: GPUBufferBinding(
                      buffer: u1
                  )
              ),
              BindGroupEntry(
                  binding: 4,
                  resource: GPUBufferBinding(
                      buffer: u2
                  )
              ),
              BindGroupEntry(
                  binding: 5,
                  resource: GPUBufferBinding(
                      buffer: _heatmap
                  )
              ),
              BindGroupEntry(
                  binding: 6,
                  resource: GPUBufferBinding(
                      buffer: _maxHeat
                  )
              ),
            ].toJS
        )
      );
}