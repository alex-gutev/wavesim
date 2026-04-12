import 'dart:typed_data' as types;
import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import 'downsampler.dart';
import 'sim_buffer.dart';
import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

part 'grid_renderer.g.dart';

@EmbedStr('/shaders/grid.wgsl')
final gridShaderSrc = _$gridShaderSrc;

/// Renders a simulation as a grid.
///
/// This renderer draws a grid. For grids larger than
/// 50x50, downsampling is performed.
class GridRenderer implements WavesimRenderer {
  /// Maximum size of grid to render.
  ///
  /// If the simulation grid is larger than this size, a downsampled output
  /// is rendered.
  static const maxSize = 50;

  /// The GPU device
  final GPUDevice device;

  /// The canvas context to render to
  final GPUCanvasContext context;

  GridRenderer({
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
          BindEntry(
              binding: 1,
              visibility: $GPUShaderStage.VERTEX,
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
    required int size,
    required GPUBuffer sizeBuffer,
    required SimBuffer buffers
  }) {
    _size = size;

    _downSampler = DownSampler(
        device: device,
        size: size,
        windowSize: size > maxSize ? (size / maxSize).ceil() : 1,
        blockSize: 8,
        sizeBuffer: sizeBuffer,
        buffers: buffers
    );

    final indexBuffer = _initIndices();

    _renderPipeline = device.createRenderPipeline(
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
            buffers: [indexBuffer].toJS
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
            BindGroupEntry(
                binding: 1,
                resource: GPUBufferBinding(
                    buffer: _downSampler.output
                )
            )
          ].toJS
      )
    );
  }

  @override
  void dispose() {
    _indexBuffer.destroy();
    _sizeBuffer.destroy();
  }

  @override
  void render({
    required GPUCommandEncoder encoder,
    required GPUBuffer data
  }) {
    _downSampler.addTo(encoder);

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
    render.setVertexBuffer(0, _indexBuffer);
    render.setBindGroup(0, _uniformBindGroup);
    render.draw(_nIndices);
    render.end();
  }

  // Private

  /// Module containing the vertex and fragment shaders
  late final GPUShaderModule _shader = device.createShaderModule(
    ShaderDescriptor(
      label: 'Grid graphics shader',
      code: gridShaderSrc
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

  /// Buffer holding the indices within the simulation state
  late final GPUBuffer _indexBuffer;

  /// The number of vertices
  late final int _nIndices;

  /// The rendering pipeline
  late final GPURenderPipeline _renderPipeline;

  /// Bind group for the uniform variables
  late final GPUBindGroup _uniformBindGroup;

  late final DownSampler _downSampler;

  /// Create the buffer holding the indices for each vertice.
  ///
  /// Returns a [VertexBuffer] for use in the vertex shader.
  VertexBuffer _initIndices() {
    final size = _downSampler.outputSize;
    final indices = types.Uint32List.fromList([
      for (var y = 0; y < size; y++)
        for (var x = 0; x < size; x++) ...[
          // Horizontal
          if (x < (size-1)) ...[
            x, y, x+1, y,
          ],

          // Vertical
          if (y < (size-1)) ...[
            x, y, x, y+1
          ]
        ]
    ]);

    _indexBuffer = device.makeUint32Buffer(
        data: indices,
        usage: $GPUBufferUsage.VERTEX
    );

    _nIndices = indices.length ~/ 2;

    return VertexBuffer(
        arrayStride: 2 * indices.elementSizeInBytes,
        stepMode: 'vertex',
        attributes: [
          VertexAttribute(
              shaderLocation: 0,
              offset: 0,
              format: 'uint32x2'
          )
        ].toJS,
    );
  }
}