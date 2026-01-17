import 'dart:js_interop';
import 'dart:typed_data' as types;

import 'package:wavesim/webgpu/index.dart';
import 'package:web/web.dart';

/// Simulates an open boundary leading to an infinite grid.
///
/// This class computes the boundary values to approximate an open boundary
/// that is an infinitely sized grid.
class OpenBoundarySimulator {
  /// The device on which to run the computation
  final GPUDevice device;

  /// The shader module containing the shader program
  final GPUShaderModule shader;

  /// Size of the grid
  final int size;

  /// Workgroup block size
  final int blockSize;

  /// Buffer holding the grid size
  final GPUBuffer sizeBuffer;

  /// Buffer holding coefficients for computing the edge values
  final GPUBuffer edgeFactors;

  /// Buffer into which to write the computed boundary values.
  final GPUBuffer edgeValues;

  /// Granule displacement buffer 1
  final GPUBuffer u1;

  /// Granule displacement buffer 2
  final GPUBuffer u2;

  OpenBoundarySimulator({
    required this.device,
    required this.shader,
    required this.size,
    required this.blockSize,
    required this.sizeBuffer,
    required this.edgeFactors,
    required this.edgeValues,
    required this.u1,
    required this.u2
  }) {
    _initBuffers();
    _initCompute();
  }

  /// Add computation of the boundary values to the command [encoder].
  void addTo(GPUCommandEncoder encoder) {
    // Calculate boundary values step

    final calcEdge = encoder.beginComputePass();

    calcEdge.setPipeline(_pipelineCalcEdge);
    calcEdge.setBindGroup(0, _bindGroup0);
    calcEdge.setBindGroup(1, _bindGroup1);

    final nWorkGroups = (size / blockSize).ceil();
    calcEdge.dispatchWorkgroups(nWorkGroups);

    calcEdge.end();

    // Shift previous values step

    final shiftEdge = encoder.beginComputePass();

    shiftEdge.setPipeline(_pipelineShiftEdge);
    shiftEdge.setBindGroup(0, _bindGroup0);
    shiftEdge.setBindGroup(1, _bindGroup1);
    shiftEdge.dispatchWorkgroups(nWorkGroups, nWorkGroups);

    shiftEdge.end();

    _firstBuf = !_firstBuf;
  }

  // Private

  /// Buffers holding the previous displacements of the granules at the edges
  late final GPUBuffer _prevEdgeValues1;
  late final GPUBuffer _prevEdgeValues2;

  /// Pipeline for calculating the boundary values
  late final GPUComputePipeline _pipelineCalcEdge;

  /// Pipeline for shifting the previous displacement values
  late final GPUComputePipeline _pipelineShiftEdge;

  late final GPUBindGroup _bindGroup0a;
  late final GPUBindGroup _bindGroup0b;
  
  late final GPUBindGroup _bindGroup1a;
  late final GPUBindGroup _bindGroup1b;

  /// If true [_prevEdgeValues1] and [u1] are used, otherwise [_prevEdgeValues2] and [u2] are used.
  var _firstBuf = true;

  GPUBindGroup get _bindGroup0 => _firstBuf ? _bindGroup0a : _bindGroup0b;
  GPUBindGroup get _bindGroup1 => _firstBuf ? _bindGroup1a : _bindGroup1b;

  /// Create the required GPU buffers
  void _initBuffers() {
    final data = types.Float32List(4 * size * size);

    _prevEdgeValues1 = device.makeFloat32Buffer(
        data: data,
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.COPY_DST |
          $GPUBufferUsage.UNIFORM
    );

    _prevEdgeValues2 = device.makeFloat32Buffer(
        data: data,
        usage: $GPUBufferUsage.STORAGE |
        $GPUBufferUsage.COPY_DST |
        $GPUBufferUsage.UNIFORM
    );
  }

  /// Initialize the computation pipelines
  void _initCompute() {
    final bindGroupLayout0 = device.createBindGroupLayout(
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
                  binding: 3,
                  visibility: $GPUShaderStage.COMPUTE,
                  buffer: BufferLayout(
                      type: 'read-only-storage'
                  )
              ),
            ].toJS
        )
    );

    final bindGroupLayout1 = device.createBindGroupLayout(
        BindGroupLayoutDescriptor(
            entries: [
              BindEntry(
                  binding: 0,
                  visibility: $GPUShaderStage.COMPUTE,
                  buffer: BufferLayout(
                      type: 'read-only-storage'
                  )

              ),
              BindEntry(
                  binding: 1,
                  visibility: $GPUShaderStage.COMPUTE,
                  buffer: BufferLayout(
                      type: 'read-only-storage'
                  )

              ),
              BindEntry(
                  binding: 2,
                  visibility: $GPUShaderStage.COMPUTE,
                  buffer: BufferLayout(
                      type: 'storage'
                  )

              ),
              BindEntry(
                  binding: 3,
                  visibility: $GPUShaderStage.COMPUTE,
                  buffer: BufferLayout(
                      type: 'storage'
                  )

              )
            ].toJS
        )
    );

    _pipelineCalcEdge = device.createComputePipeline(
        ComputePipelineLayout(
          layout: device.createPipelineLayout(
              PipelineLayoutDescriptor(
                  bindGroupLayouts: [
                    bindGroupLayout0,
                    bindGroupLayout1
                  ].toJS
              )
          ),
          compute: ComputeDescriptor(
              module: shader,
              entryPoint: 'computeBoundary',
              constants: {
                'blockSize': blockSize
              }.jsify()
          ),
        )
    );

    _pipelineShiftEdge = device.createComputePipeline(
        ComputePipelineLayout(
          layout: device.createPipelineLayout(
              PipelineLayoutDescriptor(
                  bindGroupLayouts: [
                    bindGroupLayout0,
                    bindGroupLayout1
                  ].toJS
              )
          ),
          compute: ComputeDescriptor(
              module: shader,
              entryPoint: 'shiftPrevEdges',
              constants: {
                'blockSize': blockSize
              }.jsify()
          ),
        )
    );

    _bindGroup0a = _makeBindGroup0(layout: bindGroupLayout0, data: u1);
    _bindGroup0b = _makeBindGroup0(layout: bindGroupLayout0, data: u2);

    _bindGroup1a = _makeBindGroup1(
        layout: bindGroupLayout1,
        input: _prevEdgeValues1,
        output: _prevEdgeValues2
    );

    _bindGroup1b = _makeBindGroup1(
        layout: bindGroupLayout1,
        input: _prevEdgeValues2,
        output: _prevEdgeValues1
    );
  }

  GPUBindGroup _makeBindGroup0({
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
              binding: 3,
              resource: GPUBufferBinding(
                  buffer: data
              )
          ),
        ].toJS
    )
  );

  GPUBindGroup _makeBindGroup1({
    required GPUBindGroupLayout layout,
    required GPUBuffer input, 
    required GPUBuffer output
  }) => device.createBindGroup(
    BindGroupDescriptor(
        layout: layout, 
        entries: [
          BindGroupEntry(
              binding: 0, 
              resource: GPUBufferBinding(
                buffer: edgeFactors
              )
          ),
          BindGroupEntry(
              binding: 1, 
              resource: GPUBufferBinding(
                buffer: input
              )
          ),
          BindGroupEntry(
              binding: 2,
              resource: GPUBufferBinding(
                  buffer: output
              )
          ),
          BindGroupEntry(
            binding: 3,
            resource: GPUBufferBinding(
              buffer: edgeValues
            )
          )
        ].toJS
    )
  );
}