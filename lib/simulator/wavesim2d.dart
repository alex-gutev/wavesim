import 'dart:math';
import 'dart:typed_data' as types;

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';
import 'package:embed_annotation/embed_annotation.dart';

import 'sim_buffer.dart';
import 'wavesim_engine_2d.dart';
import '../webgpu/index.dart';
import 'wavesim_renderer.dart';
import 'open_boundary_simulator.dart';

part 'wavesim2d.g.dart';

@EmbedStr('/shaders/compute.wgsl')
final computeShaderSrc = _$computeShaderSrc;

/// 2D longitudinal wave simulator
class Wavesim2d implements WavesimEngine2D {
  /// The size of the grid.
  @override
  final int size;

  /// GPU computation block size
  final int blockSize;

  /// The GPU device
  final GPUDevice device;

  /// Renderer to use for rendering the simulation
  WavesimRenderer get renderer => _renderer;

  set renderer(WavesimRenderer renderer) {
    final oldRenderer = _renderer;

    _renderer = renderer;

    _initRenderer();
    _disposeRenderer(oldRenderer);

    render();
  }

  /// The current simulation time
  @override
  int get time => _time;

  /// Energy transfer coefficient in the range (0, 1].
  double get c => _c;

  set c(double value) {
    assert((_c > 0) && (_c <= 1));

    _c = value;
    _setC(value);
  }

  /// The number of granules in the grid
  int get area => size * size;

  /// Is the boundary closed (true) or open (false)
  bool get closed => _closed;

  set closed(bool value) {
    _closed = value;

    if (_closed) {
      _clearBoundary();
    }
  }

  Wavesim2d({
    required this.device,
    required WavesimRenderer renderer,
    required this.size,
    required double c,
    this.blockSize = 8,
    bool closed = false
  }) : _renderer = renderer, _c = c, _closed = closed {
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
                  type: 'read-only-storage'
              )
          ),
        ].toJS
      )
    );

    _initCompute();
    _initRenderer();
  }

  /// Clear the simulation.
  ///
  /// This resets the simulation grid to the equilibrium state.
  void clear() {
    final encoder = device.createCommandEncoder();

    _buffers.clear(encoder);
    encoder.clearBuffer(_edge);

    _edgeSim.clear(encoder);

    _renderer.render(
        encoder: encoder,
        data: _buffers.current
    );

    device.queue.submit([encoder.finish()].toJS);
  }

  /// Dispose resources acquired by this object
  Future<void> dispose() async {
    await _disposeRenderer(_renderer);

    _sizeBuffer.destroy();
    _paramsBuffer.destroy();
    _buffers.dispose();
    _damping.destroy();
    _edge.destroy();
    _edgeFactors.destroy();
    _edgeSim.dispose();
  }

  /// Displace a granule at a given point ([x], [y]).
  ///
  /// [dx] is the magnitude of the displacement along the x-axis and [dy] is
  /// the magnitude of the displacement along the y-axis.
  ///
  /// If [vx] and [vy] are not null, the velocity of the granule at ([x], [y])
  /// is set to [vx] and [vy] along the x and y axes respectively.
  /// If [vx] and [vy] are null, the velocity of the granule is set to
  /// [dx] and [dy] in the x and y axes respectively.
  ///
  /// A negative [x] / [y] is interpreted relative to the right/bottom edge of
  /// the visible grid.
  @override
  void displace({
    required int x,
    required int y,
    required double dx,
    required double dy,
    double? vx,
    double? vy
  }) {
    final i = _index(x, y);
    final offset = i * types.Float32List.bytesPerElement;

    device.queue.writeBuffer(
        _buffers.current,
        offset,
        types.Float32List.fromList([dx, dy]).toJS
    );

    device.queue.writeBuffer(
        _buffers.previous,
        offset,
        types.Float32List.fromList([
          vx != null ? dx - vx : 0,
          vy != null ? dy - vy : 0
        ]).toJS
    );
  }

  /// Update the state of the simulation by a single step.
  Future<void> update() async {
    final bindGroup = _buffers.isFirst ? _bindGroup1 : _bindGroup2;
    final encoder = device.createCommandEncoder();

    if (!closed) {
      _edgeSim.addTo(encoder);
    }
    
    final compute = encoder.beginComputePass();

    compute.setPipeline(_computePipeline);
    compute.setBindGroup(0, bindGroup);

    final nWorkgroups = (size / blockSize).ceil();
    compute.dispatchWorkgroups(nWorkgroups, nWorkgroups);

    compute.end();

    _renderer.render(
        encoder: encoder,
        data: _buffers.previous
    );

    device.queue.submit([encoder.finish()].toJS);
    await device.queue.onSubmittedWorkDone().toDart;

    _buffers.swap();
    _time++;
  }

  /// Render the current state of the simulator
  Future<void> render() async {
    final encoder = device.createCommandEncoder();

    _renderer.render(
        encoder: encoder,
        data: _buffers.current
    );

    device.queue.submit([encoder.finish()].toJS);
    await device.queue.onSubmittedWorkDone().toDart;
  }

  // Private

  /// Shader module containing the shader that computes the simulation state.
  late final GPUShaderModule _shader = device.createShaderModule(
      ShaderDescriptor(
          label: 'Wavesim2D compute shader',
          code: computeShaderSrc
      )
  );

  /// Energy transfer coefficient in the range (0, 1].
  double _c;

  /// Renderer to use for rendering the simulation
  WavesimRenderer _renderer;

  /// Is the simulation boundary closed or open?
  bool _closed;

  /// The number of previous boundary values to use
  late final _edgeSize = min(50, size);

  /// Compute shader binding layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// Computational pipeline
  late final GPUComputePipeline _computePipeline;

  /// Buffer holding the size of the grid
  late final GPUBuffer _sizeBuffer;

  /// Buffer holding the simulation parameters (c).
  late final GPUBuffer _paramsBuffer;

  /// Buffers holding the simulation state
  late final SimBuffer _buffers;

  /// Buffer holding the damping coefficients of the grid
  late final GPUBuffer _damping;

  /// Buffer holding the boundary values
  ///
  /// This buffer holds the values at left and right boundaries followed by the
  /// values at the top and bottom boundaries.
  late final GPUBuffer _edge;

  /// Buffer holding the coefficients for computing the boundary values
  late final GPUBuffer _edgeFactors;

  /// Open boundary simulator
  late final OpenBoundarySimulator _edgeSim;

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

  void _setC(double value) {
    device.queue.writeBuffer(
        _edgeFactors,
        0,
        _calcEdgeFactors(_edgeSize, value).toJS
    );

    device.queue.writeBuffer(
        _paramsBuffer,
        0,
        types.Float32List.fromList([value]).toJS
    );
  }

  /// Get the absolute X coordinate of a granule.
  ///
  /// If [x] is less than zero it is interpreted relative to the right edge
  /// of the grid.
  int _xIndex(int x) => x < 0 ? x + size : x;

  /// Get the absolute Y coordinate of a granule.
  ///
  /// If [y] is less than zero it is interpreted relative to the bottom edge
  /// of the visible grid.
  int _yIndex(int y) => y < 0 ? y + size : y;

  /// Get the index of the buffer element holding the state of a granule.
  ///
  /// A negative [x]/[y] is interpreted relative to the right /
  /// bottom edge of the visible grid.
  int _index(int x, int y) => 2 * (_yIndex(y) * size + _xIndex(x));

  void _initCompute() {
    _computePipeline = device.createComputePipeline(
      ComputePipelineLayout(
        layout: device.createPipelineLayout(
            PipelineLayoutDescriptor(
              bindGroupLayouts: [_bindGroupLayout].toJS
            )
        ),
        compute: ComputeDescriptor(
          module: _shader,
          entryPoint: 'main',
          constants: {
            'blockSize': blockSize
          }.jsify()
        )
      )
    );

    // NOTE: Even though the binding is of type u32, WebGPU complains if the
    // size of the buffer is less than 8 bytes.
    _sizeBuffer = _makeUInt32Buffer(
        types.Uint32List.fromList([size, size])
    );

    _paramsBuffer = _makeFloat32Buffer(
      types.Float32List.fromList([c])
    );

    final u1 = _makePosBuffer();
    final u2 = _makePosBuffer();

    _buffers = SimBuffer(
        buffer1: u1,
        buffer2: u2
    );

    _initDamping();
    _initBoundary();

    _bindGroup1 = _makeBindGroup(u1, u2);
    _bindGroup2 = _makeBindGroup(u2, u1);

    _time = 0;
  }

  void _initRenderer() {
    _renderer.init(
        size: size,
        sizeBuffer: _sizeBuffer,
        buffers: _buffers
    );
  }

  /// Create a buffer for holding the simulation state.
  GPUBuffer _makePosBuffer() => _makeFloat32Buffer(
    types.Float32List(2 * area),
    usage: $GPUBufferUsage.STORAGE |
      $GPUBufferUsage.VERTEX |
      $GPUBufferUsage.COPY_DST |
      $GPUBufferUsage.COPY_SRC,
  );

  /// Initialize the buffer holding the damping coefficients.
  void _initDamping() {
     _damping = _makeFloat32Buffer(
       types.Float32List(area)..fillRange(0, area, 1),
       usage: $GPUBufferUsage.STORAGE |
        $GPUBufferUsage.UNIFORM,
     );
  }

  /// Initialize the buffers for computing the boundary values
  void _initBoundary() {
    _edge = _makeFloat32Buffer(
      types.Float32List(2 * size * 4),
      usage: $GPUBufferUsage.STORAGE |
        $GPUBufferUsage.COPY_DST
    );

    _edgeFactors = _makeFloat32Buffer(
        _calcEdgeFactors(_edgeSize, c),
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.COPY_DST
    );

    _edgeSim = OpenBoundarySimulator(
        device: device,
        shader: _shader,
        size: size,
        edgeSize: _edgeSize,
        blockSize: blockSize,
        sizeBuffer: _sizeBuffer,
        edgeFactors: _edgeFactors,
        edgeValues: _edge,
        buffers: _buffers,
    );
  }

  /// Calculate the boundary coefficients for a given grid [size] and wave speed [c].
  static types.Float32List _calcEdgeFactors(int size, double c) {
    final data = types.Float32List(size * size);
    final cache = <(int,int,int), double>{};

    double calc(int x, int y, int tn) =>
        cache.putIfAbsent((x, y, tn), () {
          if (x == 0 && y == 0 && tn == 0) {
            return 1;
          }
          else if ((x == 0 && tn != 0) || tn < 0) {
            return 0;
          }
          else if (tn < y) {
            return 0;
          }

          final tprev = tn - 1;

          final l = calc(x - 1, y, tprev);
          final r = calc(x + 1, y, tprev);
          final t = calc(x, y - 1, tprev);
          final b = calc(x, y + 1, tprev);

          final u = calc(x, y, tprev);
          final a = c * (l + r + t + b - 4 * u) / 4;
          final v = u - calc(x, y, tn - 2);

          return u + v + a;
        });

    for (var y = 0; y < size; y++) {
      for (var t = 0; t < size; t++) {
        final c = calc(1, y, t+1);

        data[y*size + t] = c;
      }
    }

    return data;
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
                      buffer: _edge,
                  )
              ),
            ].toJS
        )
      );

  /// Call dispose on a given [renderer].
  ///
  /// This method takes care to dispose the [renderer] after all work on the
  /// GPU queue has completed, in order to be sure that the renderer wont be
  /// used again.
  Future<void> _disposeRenderer(WavesimRenderer renderer) async {
    await device.queue.onSubmittedWorkDone().toDart;
    renderer.dispose();
  }

  /// Clear the state of the boundary simulator.
  void _clearBoundary() {
    final encoder = device.createCommandEncoder();

    encoder.clearBuffer(_edge);
    _edgeSim.clear(encoder);

    device.queue.submit([encoder.finish()].toJS);
  }
}