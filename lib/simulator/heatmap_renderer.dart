import 'dart:typed_data' as types;
import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import 'compute_heatmap.dart';
import 'sim_buffer.dart';
import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

part 'heatmap_renderer.g.dart';

@EmbedStr('/shaders/heatmap.wgsl')
final heatmapShaderSrc = _$heatmapShaderSrc;

class HeatmapRenderer implements WavesimRenderer {
  /// The GPU device
  final GPUDevice device;

  /// The canvas context to render to
  final GPUCanvasContext context;

  HeatmapRenderer({
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
    required int size,
    required GPUBuffer sizeBuffer,
    required SimBuffer buffers
  }) {
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

    _computeHeatmap = ComputeHeatmap(
        device: device,
        size: size,
        windowSize: 1,
        blockSize: 8,
        sizeBuffer: sizeBuffer,
        buffers: buffers
    );

    final heatmapSize = _computeHeatmap.heatmapSize - 1;

    _heatmapIndexBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          0, 0,
          0, heatmapSize,
          heatmapSize, 0,
          heatmapSize, heatmapSize
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
                    buffer: _computeHeatmap.heatmap
                )
            ),
            BindGroupEntry(
                binding: 2,
                resource: GPUBufferBinding(
                    buffer: _computeHeatmap.maxHeat
                )
            )
          ].toJS
      )
    );
  }

  @override
  void dispose() {
    _vertBuffer.destroy();
    _heatmapIndexBuffer.destroy();
    _computeHeatmap.dispose();
  }

  @override
  void render({required GPUCommandEncoder encoder, required GPUBuffer data}) {
    _computeHeatmap.addTo(encoder);

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
    render.setVertexBuffer(1, _heatmapIndexBuffer);
    render.setBindGroup(0, _uniformBindGroup);
    render.draw(4);
    render.end();
  }

  // Private

  /// Module containing the vertex and fragment shaders
  late final GPUShaderModule shader = device.createShaderModule(
    ShaderDescriptor(
      label: 'Heatmap graphics shader',
      code: heatmapShaderSrc
    )
  );

  /// Output format
  late final String format;

  /// Vertex and fragment shader bind group layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// Buffer holding the vertex positions
  late final GPUBuffer _vertBuffer;

  /// Buffer holding the heatmap coordinates associated with each vertex
  late final GPUBuffer _heatmapIndexBuffer;

  /// The rendering pipeline
  late final GPURenderPipeline _renderPipeline;

  /// Bind group for the uniform variables
  late final GPUBindGroup _uniformBindGroup;

  late final ComputeHeatmap _computeHeatmap;
}