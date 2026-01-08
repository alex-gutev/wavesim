import 'dart:js_interop';
import 'dart:typed_data' as types;
import 'package:web/web.dart';

import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

class HeatmapRenderer implements WavesimRenderer {
  /// The GPU device
  final GPUDevice device;

  /// Module containing the vertex and fragment shaders
  final GPUShaderModule shader;

  /// The canvas context to render to
  final GPUCanvasContext context;

  HeatmapRenderer({
    required this.device,
    required this.shader,
    required this.context
  }) {
    format = window.navigator.gpu!.getPreferredCanvasFormat();

    context.configure(
        CanvasConfiguration(
            device: device,
            format: format,
            alphaMode: 'premultiplied'
        )
    );

    _bindGroupLayout = device.createBindGroupLayout(
      BindGroupLayoutDescriptor(
        entries: [
          BindEntry(
              binding: 0,
              visibility: $GPUShaderStage.FRAGMENT,
              buffer: BufferLayout(
                type: 'uniform'
              )
          ),
          BindEntry(
              binding: 1,
              visibility: $GPUShaderStage.FRAGMENT,
              buffer: BufferLayout(
                  type: 'read-only-storage'
              )
          ),
          BindEntry(
              binding: 2,
              visibility: $GPUShaderStage.FRAGMENT,
              buffer: BufferLayout(
                  type: 'read-only-storage'
              )
          ),
        ].toJS
      )
    );
  }

  @override
  void init({
    required Size gridSize,
    required Size visibleSize,
    required GPUBuffer sizeBuffer,
    required GPUBuffer heatmap,
    required GPUBuffer maxHeat
  }) {
    _gridSize = gridSize;
    _visibleSize = visibleSize;

    _vertBuffer = device.makeFloat32Buffer(
        data: types.Float32List.fromList([
          -1, -1,
          -1, 1,
          1, -1,
          1, 1
        ]),

        usage: $GPUBufferUsage.VERTEX
    );

    final vertAttrib = VertexBuffer(
        arrayStride: 2 * types.Float32List.bytesPerElement,
        stepMode: 'vertex',
        attributes: [
          VertexAttribute(
              shaderLocation: 0,
              offset: 0,
              format: 'float32x2'
          )
        ].toJS
    );

    final xOffset = (gridSize.width - visibleSize.width) ~/ 2;
    final yOffset = (gridSize.height - visibleSize.height) ~/ 2;

    _heatBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          xOffset, yOffset,
          xOffset, yOffset + visibleSize.height,
          xOffset + visibleSize.width, yOffset,
          xOffset + visibleSize.width, yOffset + visibleSize.height
        ]),

        usage: $GPUBufferUsage.VERTEX
    );

    final heatAttrib = VertexBuffer(
        arrayStride: 2 * types.Uint32List.bytesPerElement,
        stepMode: 'vertex',
        attributes: [
          VertexAttribute(
              shaderLocation: 1,
              offset: 0,
              format: 'uint32x2'
          )
        ].toJS,
    );

    _renderPipeline = device.createRenderPipeline(
      RenderPipelineLayout(
          layout: device.createPipelineLayout(
            PipelineLayoutDescriptor(
                bindGroupLayouts: [_bindGroupLayout].toJS
            )
          ),

          primitive: Primitive(
              topology: 'triangle-strip'
          ),

          vertex: Vertex(
            module: shader,
            buffers: [vertAttrib, heatAttrib].toJS
          ),
          fragment: Fragment(
              module: shader,
              targets: [
                FragmentTarget(
                    format: format
                )
              ].toJS
          )
      )
    );

    _uniformBindGroup = device.createBindGroup(
      BindGroupDescriptor(
          layout: _bindGroupLayout,
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
                    buffer: heatmap
                )
            ),
            BindGroupEntry(
                binding: 2,
                resource: GPUBufferBinding(
                    buffer: maxHeat
                )
            )
          ].toJS
      )
    );
  }

  @override
  void render({required GPUCommandEncoder encoder, required GPUBuffer data}) {
    final view = context.getCurrentTexture();

    final render = encoder.beginRenderPass(
        RenderPassDescriptor(
            colorAttachments: [
              ColorAttachment(
                  loadOp: 'clear',
                  storeOp: 'store',
                  view: view
              )
            ].toJS
        )
    );

    render.setPipeline(_renderPipeline);
    render.setVertexBuffer(0, _vertBuffer);
    render.setVertexBuffer(1, _heatBuffer);
    render.setBindGroup(0, _uniformBindGroup);
    render.draw(4);
    render.end();
  }

  // Private

  /// Output format
  late final String format;

  /// Vertex and fragment shader bind group layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// The size of the entire grid
  late final Size _gridSize;

  /// The size of the grid that is visible
  late final Size _visibleSize;

  /// Buffer holding the vertex positions
  late final GPUBuffer _vertBuffer;

  /// Buffer holding the heatmap coordinates associated with each vertex
  late final GPUBuffer _heatBuffer;

  /// The rendering pipeline
  late final GPURenderPipeline _renderPipeline;

  /// Bind group for the uniform variables
  late final GPUBindGroup _uniformBindGroup;
}