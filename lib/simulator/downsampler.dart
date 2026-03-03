import 'dart:typed_data' as types;
import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import 'sim_buffer.dart';
import '../webgpu/index.dart';

part 'downsampler.g.dart';

/// Downsampling shader source
@EmbedStr('/shaders/downsample.wgsl')
final downSampleSrc = _$downSampleSrc;

/// Downsamples the simulation state output.
///
/// The downsampling is done by averaging over a given window.
class DownSampler {
  /// The device on which to run the computation
  final GPUDevice device;

  /// The shader module containing the shader program
  late final GPUShaderModule shader = device.createShaderModule(
      ShaderDescriptor(
          label: 'Wavesim2D Downsampling Shader',
          code: downSampleSrc
      )
  );

  /// Size of the grid
  final int size;

  /// Size of the downsampling window
  final int windowSize;

  /// Workgroup block size
  final int blockSize;

  /// Buffer holding the grid size
  final GPUBuffer sizeBuffer;

  /// Simulation state buffers
  final SimBuffer buffers;

  /// Size of the downsampled output
  late final outputSize = (size / windowSize).ceil();

  /// Downsampled output buffer
  GPUBuffer get output => _outputBuffer;

  DownSampler({
    required this.device,
    required this.size,
    required this.windowSize,
    required this.blockSize,
    required this.buffers,
    required this.sizeBuffer,
  }) {
    _initBuffers();
    _initCompute();
  }

  /// Dispose all buffers held by this object
  void dispose() {
    _windowSizeBuffer.destroy();
    _outputSizeBuffer.destroy();
    _outputBuffer.destroy();
  }

  /// Add the downsampling commands to a given command [encoder].
  void addTo(GPUCommandEncoder encoder) {
    final compute = encoder.beginComputePass();

    compute.setPipeline(_pipeline);
    compute.setBindGroup(0, _group);

    final nWorkGroups = (outputSize / blockSize).ceil();
    compute.dispatchWorkgroups(nWorkGroups, nWorkGroups);

    compute.end();
  }

  // Private

  /// Buffer holding the downsampling window size
  late final GPUBuffer _windowSizeBuffer;

  /// Buffer holding the output buffer size
  late final GPUBuffer _outputSizeBuffer;

  /// Buffer holding the downsampled output
  late final GPUBuffer _outputBuffer;

  /// Downsampling compute pipeline
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

    _outputSizeBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          outputSize
        ]),
        usage: $GPUBufferUsage.UNIFORM
    );

    _outputBuffer = device.makeFloat32Buffer(
        data: types.Float32List(2 * outputSize * outputSize),
        usage: $GPUBufferUsage.STORAGE | $GPUBufferUsage.VERTEX
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
            entryPoint: 'downsample',
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
                  buffer: _outputSizeBuffer
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
                  buffer: _outputBuffer
              )
          ),
        ].toJS
    )
  );
}