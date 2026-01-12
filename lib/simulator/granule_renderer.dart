import 'dart:js_interop';
import 'dart:typed_data' as types;
import 'package:web/web.dart';

import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

/// Renders a simulation as a grid of individual granules.
///
/// This renderer draws each granule at its displaced position. This is suitable
/// for small grids however is slow for large grids (larger than 100x100).
class GranuleRenderer implements WavesimRenderer {
  /// The GPU device
  final GPUDevice device;

  /// Module containing the vertex and fragment shaders
  final GPUShaderModule shader;

  /// The canvas context to render to
  final GPUCanvasContext context;

  GranuleRenderer({
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
              visibility: $GPUShaderStage.VERTEX,
              buffer: BufferLayout(
                  type: 'uniform'
              )
          ),
          BindEntry(
              binding: 1,
              visibility: $GPUShaderStage.VERTEX,
              buffer: BufferLayout(
                  type: 'uniform'
              )
          ),
          BindEntry(
              binding: 2,
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
    required Size gridSize,
    required Size visibleSize,
    required GPUBuffer sizeBuffer,
    required GPUBuffer heatmap,
    required GPUBuffer maxHeat
  }) {
    _gridSize = gridSize;
    _visibleSize = visibleSize;

    _visibleSizeBuffer = _makeSizeBuffer(visibleSize);

    _visibleOffsetBuffer = _makeSizeBuffer(
      Size(
          width: (gridSize.width - visibleSize.width) ~/ 2,
          height: (gridSize.height - visibleSize.height) ~/ 2
      )
    );

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
            module: shader,
            buffers: [uBuffer, vertBuffer].toJS
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
                  buffer: sizeBuffer,
                )
            ),
            BindGroupEntry(
                binding: 1,
                resource: GPUBufferBinding(
                  buffer: _visibleSizeBuffer,
                )
            ),
            BindGroupEntry(
                binding: 2,
                resource: GPUBufferBinding(
                  buffer: _visibleOffsetBuffer,
                )
            ),
          ].toJS
      )
    );
  }

  @override
  void dispose() {
    _vertBuffer.destroy();
    _visibleSizeBuffer.destroy();
    _visibleOffsetBuffer.destroy();
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
    render.draw(4, _gridSize.area);
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

  /// Buffer holding the size of the visible grid
  late final GPUBuffer _visibleSizeBuffer;

  /// Buffer holding the X and Y offsets to the visible grid
  late final GPUBuffer _visibleOffsetBuffer;

  /// Buffer holding the vertex positions
  late final GPUBuffer _vertBuffer;

  /// The rendering pipeline
  late final GPURenderPipeline _renderPipeline;

  /// Bind group for the uniform variables
  late final GPUBindGroup _uniformBindGroup;

  /// Create a GPU buffer holding the width and height of a given [size].
  GPUBuffer _makeSizeBuffer(Size size) {
    return device.makeUint32Buffer(
        data: types.Uint32List.fromList([size.width, size.height]),
        usage: $GPUBufferUsage.STORAGE |
          $GPUBufferUsage.UNIFORM |
          $GPUBufferUsage.COPY_DST |
          $GPUBufferUsage.VERTEX
    );
  }

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