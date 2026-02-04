import 'dart:typed_data' as types;
import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

part 'granule_renderer.g.dart';

@EmbedStr('/shaders/blocks.wgsl')
final blockShaderSrc = _$blockShaderSrc;

/// Renders a simulation as a grid of individual granules.
///
/// This renderer draws each granule at its displaced position. This is suitable
/// for small grids however is slow for large grids (larger than 100x100).
class GranuleRenderer implements WavesimRenderer {
  /// The GPU device
  final GPUDevice device;

  /// The canvas context to render to
  final GPUCanvasContext context;

  GranuleRenderer({
    required this.device,
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
              visibility: $GPUShaderStage.VERTEX,
              buffer: BufferLayout(
                  type: 'uniform'
              )
          ),
        ].toJS
      )
    );
  }

  @override
  void init({
    required int size,
    required GPUBuffer sizeBuffer,
    required GPUBuffer heatmap,
    required GPUBuffer maxHeat
  }) {
    _size = size;

    final vertBuffer = _initVertices();
    
    final uBuffer = VertexBuffer(
        arrayStride: 2 * types.Float32List.bytesPerElement,
        stepMode: 'instance',
        attributes: [
          VertexAttribute(
              shaderLocation: 0,
              offset: 0,
              format: 'float32x2'
          )
        ].toJS
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
            module: _shader,
            buffers: [uBuffer, vertBuffer].toJS
          ),

          fragment: Fragment(
              module: _shader, 
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
                  buffer: sizeBuffer,
                )
            ),
          ].toJS
      )
    );
  }

  @override
  void dispose() {
    _vertBuffer.destroy();
  }

  @override
  void render({
    required GPUCommandEncoder encoder,
    required GPUBuffer data
  }) {
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
    render.setVertexBuffer(0, data);
    render.setVertexBuffer(1, _vertBuffer);
    render.setBindGroup(0, _uniformBindGroup);
    render.draw(4, _size * _size);
    render.end();
  }

  // Private

  /// Module containing the vertex and fragment shaders
  late final GPUShaderModule _shader = device.createShaderModule(
    ShaderDescriptor(
      label: 'Block graphics shader',
      code: blockShaderSrc
    )
  );

  /// Output format
  late final String format;

  /// Vertex and fragment shader bind group layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// The size of the grid
  late final int _size;

  /// Buffer holding the vertex positions
  late final GPUBuffer _vertBuffer;

  /// The rendering pipeline
  late final GPURenderPipeline _renderPipeline;

  /// Bind group for the uniform variables
  late final GPUBindGroup _uniformBindGroup;

  /// Create the buffer holding the positions of the vertices.
  ///
  /// Returns a [VertexBuffer] for use in the vertex shader.
  VertexBuffer _initVertices() {
    final vertices = types.Uint32List.fromList([
      0, 0,
      0, 1,
      1, 0,
      1, 1
    ]);

    _vertBuffer = device.makeUint32Buffer(
        data: vertices,
        usage: $GPUBufferUsage.VERTEX
    );

    return VertexBuffer(
        arrayStride: 2 * vertices.elementSizeInBytes,
        stepMode: 'vertex',
        attributes: [
          VertexAttribute(
              shaderLocation: 1,
              offset: 0,
              format: 'uint32x2'
          )
        ].toJS,
    );
  }
}