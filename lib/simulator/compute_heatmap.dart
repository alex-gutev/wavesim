import 'dart:typed_data' as types;

import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import '../webgpu/index.dart';
import 'sim_buffer.dart';

part 'compute_heatmap.g.dart';

/// Heatmap compute shader source
@EmbedStr('/shaders/compute_heatmap.wgsl')
final computeHeatmapSrc = _$computeHeatmapSrc;

/// Computes the heatmap (density map)
class ComputeHeatmap {
  final GPUDevice device;

  late final GPUShaderModule shader = device.createShaderModule(
    ShaderDescriptor(
      label: 'Wavesim2D Heatmap Computation Shader',
      code: computeHeatmapSrc
    )
  );

  /// Size of the grid
  final int size;

  /// Size of the window
  final int windowSize;

  /// Workgroup block size
  final int blockSize;

  /// Buffer holding the grid size
  final GPUBuffer sizeBuffer;

  /// Simulation state buffers
  final SimBuffer buffers;

  /// Size of the heatmap
  late final heatmapSize = (size / windowSize).ceil();

  /// Buffer holding the heatmap
  GPUBuffer get heatmap => _heatmap;

  /// Buffer holding the largest heat value recorded
  GPUBuffer get maxHeat => _maxHeat;

  /// Buffer holding the size of the heatmap
  GPUBuffer get heatmapSizeBuffer => _heatmapSizeBuffer;

  ComputeHeatmap({
    required this.device,
    required this.size,
    required this.windowSize,
    required this.blockSize,
    required this.sizeBuffer,
    required this.buffers
  }) {
    _initBuffers();
    _initCompute();
  }


  /// Dispose all buffers held by this object
  void dispose() {
    _windowSizeBuffer.destroy();
    _heatmapSizeBuffer.destroy();
    _heatmap.destroy();
    _maxHeat.destroy();
  }

  /// Add the compute commands to a given command [encoder].
  void addTo(GPUCommandEncoder encoder) {
    encoder.clearBuffer(_heatmap);
    encoder.clearBuffer(_maxHeat);

    final compute = encoder.beginComputePass();

    compute.setPipeline(_pipeline);
    compute.setBindGroup(0, _group);

    final nWorkGroups = (size / blockSize).ceil();
    compute.dispatchWorkgroups(nWorkGroups, nWorkGroups);

    compute.end();
  }

  // Private

  /// Buffer holding the window size
  late final GPUBuffer _windowSizeBuffer;

  /// Buffer holding the size of the heatmap output buffer
  late final GPUBuffer _heatmapSizeBuffer;

  /// Buffer holding the heatmap output
  late final GPUBuffer _heatmap;

  /// Buffer holding the maximum heat
  late final GPUBuffer _maxHeat;

  /// Heatmap compute pipeline
  late final GPUComputePipeline _pipeline;

  late final GPUBindGroup _group1;
  late final GPUBindGroup _group2;

  /// Current bind group
  GPUBindGroup get _group => buffers.isFirst ? _group1 : _group2;

  /// Create all the buffers
  void _initBuffers() {
    _windowSizeBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          windowSize
        ]),

        usage: $GPUBufferUsage.UNIFORM
    );

    _heatmapSizeBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          heatmapSize
        ]),
        usage: $GPUBufferUsage.UNIFORM
    );

    _heatmap = device.makeUint32Buffer(
        data: types.Uint32List(heatmapSize * heatmapSize),
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.VERTEX |
          $GPUBufferUsage.COPY_DST
    );

    _maxHeat = device.makeUint32Buffer(
        data: types.Uint32List.fromList([0]),
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.COPY_DST
    );
  }

  /// Create the computational pipeline
  void _initCompute() {
    final bindGroupLayout = device.createBindGroupLayout(
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
                      type: 'uniform'
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
            ].toJS
        )
    );

    _pipeline = device.createComputePipeline(
        ComputePipelineLayout(
            layout: device.createPipelineLayout(
                PipelineLayoutDescriptor(
                    bindGroupLayouts: [bindGroupLayout].toJS
                )
            ),

            compute: ComputeDescriptor(
                module: shader,
                entryPoint: 'compute_density',
                constants: {
                  'blockSize': blockSize
                }.jsify()
            )
        )
    );

    _group1 = _makeBindGroup(
        layout: bindGroupLayout,
        data: buffers.buffer1
    );

    _group2 = _makeBindGroup(
        layout: bindGroupLayout,
        data: buffers.buffer2
    );
  }

  GPUBindGroup _makeBindGroup({
    required GPUBindGroupLayout layout,
    required GPUBuffer data
  }) => device.createBindGroup(
      BindGroupDescriptor(
          layout: layout,
          entries: [
            BindGroupEntry(
                binding: 0,
                resource: GPUBufferBinding(
                    buffer: sizeBuffer
                )
            ),
            BindGroupEntry(
                binding: 1,
                resource: GPUBufferBinding(
                    buffer: _windowSizeBuffer
                )
            ),
            BindGroupEntry(
                binding: 2,
                resource: GPUBufferBinding(
                    buffer: _heatmapSizeBuffer
                )
            ),
            BindGroupEntry(
                binding: 3,
                resource: GPUBufferBinding(
                    buffer: data
                )
            ),
            BindGroupEntry(
                binding: 4,
                resource: GPUBufferBinding(
                    buffer: _heatmap
                )
            ),
            BindGroupEntry(
                binding: 5,
                resource: GPUBufferBinding(
                    buffer: _maxHeat
                )
            ),
          ].toJS
      )
  );
}
