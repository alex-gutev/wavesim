import 'dart:typed_data' as types;
import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import 'downsampler.dart';
import 'sim_buffer.dart';
import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

part 'vector_renderer.g.dart';

@EmbedStr('/shaders/vector.wgsl')
final vectorShaderSrc = _$vectorShaderSrc;

/// Renders a simulation as a grid of vectors.
///
/// This renderer draws an arrow representing each vector. For grids larger than
/// 50x50, downsampling is performed. In this case a vector represents the
/// average of multiple vectors in a given window.
class VectorRenderer implements WavesimRenderer {
  /// Maximum size of grid to render.
  ///
  /// If the simulation grid is larger than this size, a downsampled output
  /// is rendered.
  static const maxSize = 50;

  /// The GPU device
  final GPUDevice device;

  /// The canvas context to render to
  final GPUCanvasContext context;

  VectorRenderer({
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
    required GPUBuffer maxHeat,
    required SimBuffer buffers
  }) {
    _size = size;

    final lineVertBuffer = _initLineVertices();
    final arrowVertBuffer = _initArrowVertices();
    
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

    _renderPointPipeline = device.createRenderPipeline(
      RenderPipelineLayout(
          layout: device.createPipelineLayout(
            PipelineLayoutDescriptor(
              bindGroupLayouts: [_bindGroupLayout].toJS
            )
          ),

          primitive: Primitive(
              topology: 'point-list'
          ),

          vertex: Vertex(
              module: _shader,
              buffers: [uBuffer, lineVertBuffer].toJS
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

    _renderLinePipeline = device.createRenderPipeline(
      RenderPipelineLayout(
          layout: device.createPipelineLayout(
            PipelineLayoutDescriptor(
              bindGroupLayouts: [_bindGroupLayout].toJS
            )
          ),

          primitive: Primitive(
            topology: 'line-list'
          ),

          vertex: Vertex(
            module: _shader,
            buffers: [uBuffer, lineVertBuffer].toJS
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

    _renderArrowPipeline = device.createRenderPipeline(
        RenderPipelineLayout(
            layout: device.createPipelineLayout(
                PipelineLayoutDescriptor(
                    bindGroupLayouts: [_bindGroupLayout].toJS
                )
            ),

            primitive: Primitive(
                topology: 'triangle-list'
            ),

            vertex: Vertex(
                module: _shader,
                buffers: [uBuffer, arrowVertBuffer].toJS
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

    _downSampler = DownSampler(
        device: device,
        size: size,
        windowSize: size > maxSize ? (size / maxSize).ceil() : 1,
        blockSize: 8,
        sizeBuffer: sizeBuffer,
        buffers: buffers
    );

    _sizeBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          _downSampler.outputSize,
          _downSampler.outputSize,
        ]),
        usage: $GPUBufferUsage.UNIFORM
    );

    _uniformBindGroup = device.createBindGroup(
      BindGroupDescriptor(
          layout: _bindGroupLayout,
          entries: [
            BindGroupEntry(
                binding: 0,
                resource: GPUBufferBinding(
                  buffer: _sizeBuffer,
                )
            ),
          ].toJS
      )
    );
  }

  @override
  void dispose() {
    _lineVertBuffer.destroy();
    _arrowVertBuffer.destroy();
    _sizeBuffer.destroy();
  }

  @override
  void render({
    required GPUCommandEncoder encoder,
    required GPUBuffer data
  }) {
    _downSampler.addTo(encoder);

    final view = context.getCurrentTexture();

    final renderPoints = encoder.beginRenderPass(
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

    renderPoints.setPipeline(_renderPointPipeline);
    renderPoints.setVertexBuffer(0, _downSampler.output);
    renderPoints.setVertexBuffer(1, _lineVertBuffer);
    renderPoints.setBindGroup(0, _uniformBindGroup);
    renderPoints.draw(1, _downSampler.outputSize * _downSampler.outputSize);
    renderPoints.end();

    final renderLines = encoder.beginRenderPass(
      RenderPassDescriptor(
        colorAttachments: [
          ColorAttachment(
              loadOp: 'load',
              storeOp: 'store',
              view: view
          )
        ].toJS
      )
    );

    renderLines.setPipeline(_renderLinePipeline);
    renderLines.setVertexBuffer(0, _downSampler.output);
    renderLines.setVertexBuffer(1, _lineVertBuffer);
    renderLines.setBindGroup(0, _uniformBindGroup);
    renderLines.draw(2, _downSampler.outputSize * _downSampler.outputSize);
    renderLines.end();

    final renderArrows = encoder.beginRenderPass(
        RenderPassDescriptor(
            colorAttachments: [
              ColorAttachment(
                  loadOp: 'load',
                  storeOp: 'store',
                  view: view
              )
            ].toJS
        )
    );

    renderArrows.setPipeline(_renderArrowPipeline);
    renderArrows.setVertexBuffer(0, _downSampler.output);
    renderArrows.setVertexBuffer(1, _arrowVertBuffer);
    renderArrows.setBindGroup(0, _uniformBindGroup);
    renderArrows.draw(3, _downSampler.outputSize * _downSampler.outputSize);
    renderArrows.end();
  }

  // Private

  /// Module containing the vertex and fragment shaders
  late final GPUShaderModule _shader = device.createShaderModule(
    ShaderDescriptor(
      label: 'Vector graphics shader',
      code: vectorShaderSrc
    )
  );

  /// Output format
  late final String format;

  /// Vertex and fragment shader bind group layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// The size of the grid
  late final int _size;

  /// Buffer holding the size of the grid to render
  late final GPUBuffer _sizeBuffer;

  /// Buffer holding the vertex positions of the vector lines
  late final GPUBuffer _lineVertBuffer;

  /// Buffer holding the vertex positions of the vector arrows
  late final GPUBuffer _arrowVertBuffer;

  /// Pipeline for rendering the base points of the vectors
  late final GPURenderPipeline _renderPointPipeline;

  /// Pipeline for rendering the lines of the vectors
  late final GPURenderPipeline _renderLinePipeline;

  /// Pipeline for rendering the arrows of the vectors
  late final GPURenderPipeline _renderArrowPipeline;

  /// Bind group for the uniform variables
  late final GPUBindGroup _uniformBindGroup;

  late final DownSampler _downSampler;

  /// Create the buffer holding the positions of the line vertices.
  ///
  /// Returns a [VertexBuffer] for use in the vertex shader.
  VertexBuffer _initLineVertices() {
    final vertices = types.Float32List.fromList([0, 0, 0, 0.7]);

    _lineVertBuffer = device.makeFloat32Buffer(
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
              format: 'float32x2'
          )
        ].toJS,
    );
  }

  /// Create the buffer holding the positions of the arrow vertices.
  ///
  /// Returns a [VertexBuffer] for use in the vertex shader.
  VertexBuffer _initArrowVertices() {
    final vertices = types.Float32List.fromList([
      -0.5, 0.7, 0.5, 0.7, 0, 1
    ]);

    _arrowVertBuffer = device.makeFloat32Buffer(
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
            format: 'float32x2'
        )
      ].toJS,
    );
  }
}