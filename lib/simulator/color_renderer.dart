import 'dart:typed_data' as types;

import 'package:embed_annotation/embed_annotation.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import 'sim_buffer.dart';
import 'wavesim_renderer.dart';
import '../webgpu/index.dart';

part 'color_renderer.g.dart';

@EmbedStr('/shaders/color.wgsl')
final colorShaderSrc = _$colorShaderSrc;

/// Represents the peak/trough color.
class WaveColor {
  final double red;
  final double green;
  final double blue;
  final double alpha;

  const WaveColor(this.red, this.green, this.blue, [this.alpha = 1]);

  List<double> get components =>
      [red, green, blue, alpha];
}

/// Renders the simulation as a coloured grid
///
/// The colour represents the amplitude of one of the given [component]s.
class ColorRenderer implements WavesimRenderer {
  /// Color to use for maximum trough amplitude
  static const _loColor = WaveColor(0, 0, 1, 1);

  /// Color to use for maximum peak amplitude
  static const _hiColor = WaveColor(0, 1, 1, 1);

  /// The GPU device
  final GPUDevice device;

  /// The canvas context to render to
  final GPUCanvasContext context;

  /// The component to render
  ///
  /// If 0 the x component is rendered, otherwise the y component is rendered.
  final int component;

  ColorRenderer({
    required this.device,
    required this.context,
    required this.component
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
                  type: 'uniform'
              )
          ),
          BindEntry(
              binding: 2,
              visibility: $GPUShaderStage.FRAGMENT,
              buffer: BufferLayout(
                  type: 'uniform'
              )
          ),
          BindEntry(
              binding: 3,
              visibility: $GPUShaderStage.FRAGMENT,
              buffer: BufferLayout(
                  type: 'uniform'
              )
          ),
          BindEntry(
              binding: 4,
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
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void init({
    required int size,
    required GPUBuffer sizeBuffer,
    required SimBuffer buffers
  }) {
    _initBuffers(size);

    _dataBuffers = buffers;

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

    final dataPosAttrib = VertexBuffer(
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

    // TODO: Initialize remaining parameters

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
                buffers: [vertAttrib, dataPosAttrib].toJS
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

    _bindGroup1 = _makeBindGroup(
        sizeBuffer: sizeBuffer,
        data: buffers.buffer1
    );

    _bindGroup2 = _makeBindGroup(
        sizeBuffer: sizeBuffer,
        data: buffers.buffer2
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
    render.setVertexBuffer(1, _dataPosBuffer);
    render.setBindGroup(0, _bindGroup);
    render.draw(4);
    render.end();
  }

  // Private

  /// Module containing the vertex and fragment shaders
  late final GPUShaderModule shader = device.createShaderModule(
      ShaderDescriptor(
          label: 'Scalar wave graphics shader',
          code: colorShaderSrc
      )
  );

  /// Output format
  late final String format;

  /// Vertex and fragment shader bind group layout
  late final GPUBindGroupLayout _bindGroupLayout;

  /// Buffer holding component to render
  late final GPUBuffer _componentBuffer;

  /// Buffer holding trough color
  late final GPUBuffer _loColorBuffer;

  /// Buffer holding peak color
  late final GPUBuffer _hiColorBuffer;

  /// Buffer holding vertex coordinates
  late final GPUBuffer _vertBuffer;

  /// Buffer holding simulation data coordinates
  late final GPUBuffer _dataPosBuffer;

  /// Bind groups
  late final GPUBindGroup _bindGroup1;
  late final GPUBindGroup _bindGroup2;

  /// Rendering pipeline
  late final GPURenderPipeline _renderPipeline;

  /// The buffers holding the simulation state
  late final SimBuffer _dataBuffers;

  /// The current bind group.
  GPUBindGroup get _bindGroup => _dataBuffers.isFirst ? _bindGroup1 : _bindGroup2;

  void _initBuffers(int size) {
    _vertBuffer = device.makeFloat32Buffer(
        data: types.Float32List.fromList([
          -1, -1,
          -1, 1,
          1, -1,
          1, 1
        ]),

        usage: $GPUBufferUsage.VERTEX
    );

    _dataPosBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          0, 0,
          0, size,
          size, 0,
          size, size
        ]),

        usage: $GPUBufferUsage.VERTEX
    );

    _componentBuffer = device.makeUint32Buffer(
        data: types.Uint32List.fromList([
          component
        ]),
        usage: $GPUBufferUsage.UNIFORM
    );

    _loColorBuffer = device.makeFloat32Buffer(
      data: types.Float32List.fromList(_loColor.components),
      usage: $GPUBufferUsage.UNIFORM
    );

    _hiColorBuffer = device.makeFloat32Buffer(
        data: types.Float32List.fromList(_hiColor.components),
        usage: $GPUBufferUsage.UNIFORM
    );
  }

  GPUBindGroup _makeBindGroup({
    required GPUBuffer sizeBuffer,
    required GPUBuffer data
  }) => device.createBindGroup(
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
                    buffer: _componentBuffer
                )
            ),
            BindGroupEntry(
                binding: 2,
                resource: GPUBufferBinding(
                    buffer: _loColorBuffer,
                )
            ),
            BindGroupEntry(
                binding: 3,
                resource: GPUBufferBinding(
                    buffer: _hiColorBuffer,
                )
            ),
            BindGroupEntry(
                binding: 4,
                resource: GPUBufferBinding(
                    buffer: data
                )
            )
          ].toJS
      )
  );
}