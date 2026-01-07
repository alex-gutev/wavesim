import 'dart:js_interop';

import 'package:web/web.dart';

extension WebGPUExtension on Navigator {
  @JS()
  external GPU? get gpu;
}

extension type GPU._(JSObject _) implements JSObject {
  external JSPromise<GPUAdapter?> requestAdapter();
  external String getPreferredCanvasFormat();
}

extension type GPUAdapter._(JSObject _) implements JSObject {
  external JSPromise<GPUDevice> requestDevice();
}

extension type GPUDevice._(JSObject _) implements JSObject {
  external GPUQueue get queue;

  external GPUShaderModule createShaderModule(ShaderDescriptor descriptor);

  external GPUBindGroupLayout createBindGroupLayout(BindGroupLayoutDescriptor descriptor);

  external GPUPipelineLayout createPipelineLayout(PipelineLayoutDescriptor descriptor);
  external GPUComputePipeline createComputePipeline(ComputePipelineLayout descriptor);

  external GPURenderPipeline createRenderPipeline(RenderPipelineLayout descriptor);

  external GPUBuffer createBuffer(BufferDescriptor descriptor);

  external GPUBindGroup createBindGroup(BindGroupDescriptor descriptor);

  external GPUCommandEncoder createCommandEncoder();
}

extension type GPUShaderModule._(JSObject _) implements JSObject {}

extension type GPUQueue._(JSObject _) implements JSObject {
  external void submit(JSArray<GPUCommandBuffer> commandBuffers);
  external JSPromise onSubmittedWorkDone();

  external void writeBuffer(GPUBuffer buffer, int bufferOffset, JSTypedArray data, [
    int dataOffset,
    int size
  ]);
}

extension type GPUBindGroupLayout._(JSObject _) implements JSObject {}

extension type GPUComputePipeline._(JSObject _) implements JSObject {}

extension type GPUPipelineLayout._(JSObject _) implements JSObject {}

extension type GPUBuffer._(JSObject _) implements JSObject {
  external JSArrayBuffer getMappedRange();
  external void unmap();
  external void destroy();
}

extension type GPUBindGroup._(JSObject _) implements JSObject {}

extension type GPUCommandEncoder._(JSObject _) implements JSObject {
  external void clearBuffer(GPUBuffer buffer, [int? offset, int? size]);
  external GPUComputePassEncoder beginComputePass();
  external GPURenderPassEncoder beginRenderPass(RenderPassDescriptor descriptor);

  external GPUCommandBuffer finish();
}

extension type GPUComputePassEncoder._(JSObject _) implements JSObject {
  external void setPipeline(GPUComputePipeline pipeline);
  external void setBindGroup(int index, GPUBindGroup group);
  external void dispatchWorkgroups(int countX, [int? countY, int? countZ]);
  external void end();
}

extension type GPUCommandBuffer._(JSObject _) implements JSObject {}

extension type GPUCanvasContext._(JSObject _) implements JSObject {
  external void configure(CanvasConfiguration configuration);
  external GPUTexture getCurrentTexture();
}

extension type GPURenderPipeline._(JSObject _) implements JSObject {}

extension type GPURenderPassEncoder._(JSObject _) implements JSObject {
  external void setPipeline(GPURenderPipeline pipeline);
  external void setVertexBuffer(int slot, GPUBuffer buffer, [int? offset, int? size]);
  external void setBindGroup(int index, GPUBindGroup bindGroup);
  external void draw(int vertexCount, [int? instanceCount, int? firstVertex, int? firstInstance]);
  external void end();
}

extension type GPUTexture._(JSObject _) implements JSObject {}

// Descriptors

extension type BindGroupLayoutDescriptor._(JSObject _) implements JSObject {
  external BindGroupLayoutDescriptor({
    String? label,
    required JSArray<BindEntry> entries
  });

  external String? get label;
  external JSArray<BindEntry> entries;
}

extension type BindEntry._(JSObject _) implements JSObject {
  external BindEntry({
    required int binding,
    required int visibility,
    BufferLayout? buffer
  });

  external int get binding;
  external int get visibility;
  external BufferLayout? buffer;
}

extension type BufferLayout._(JSObject _) implements JSObject {
  external BufferLayout({
    required String type,
    int minBindingSize,
    int hasDynamicOffset
  });

  external bool get hasDynamicOffset;
  external int get minBindingSize;
  external String get type;
}

extension type PipelineLayoutDescriptor._(JSObject _) implements JSObject {
  external PipelineLayoutDescriptor({
    String? label,
    required JSArray<GPUBindGroupLayout?> bindGroupLayouts
  });

  external String? get label;
  external JSArray<GPUBindGroupLayout?> get bindGroupLayouts;
}

extension type ComputePipelineLayout._(JSObject _) implements JSObject {
  external ComputePipelineLayout({
    required ComputeDescriptor compute,
    required GPUPipelineLayout layout,
    String? label,
  });

  external ComputeDescriptor get compute;
  external String? get label;
  external GPUPipelineLayout get layout;
}

extension type ComputeDescriptor._(JSObject _) implements JSObject {
  external ComputeDescriptor({
    JSAny? constants,
    String? entryPoint,
    required GPUShaderModule module
  });

  external JSAny? get constants;
  external String? get entryPoint;
  external GPUShaderModule get module;
}

extension type BufferDescriptor._(JSObject _) implements JSObject {
  external BufferDescriptor({
    String? label,
    bool? mappedAtCreation,
    required int size,
    required int usage
  });

  external String? get label;
  external bool? get mappedAtCreation;
  external int get size;
  external int get usage;
}

extension type BindGroupDescriptor._(JSObject _) implements JSObject {
  external BindGroupDescriptor({
    String? label,
    required GPUBindGroupLayout layout,
    required JSArray<BindGroupEntry> entries
  });

  external String? get label;
  external GPUBindGroupLayout get layout;
  external JSArray<BindGroupEntry> get entries;
}

extension type BindGroupEntry._(JSObject _) implements JSObject {
  external BindGroupEntry({
    required int binding,
    required GPUBufferBinding resource
  });

  external int get binding;
  external GPUBufferBinding resource;
}

extension type GPUBufferBinding._(JSObject _) implements JSObject {
  external GPUBufferBinding({
    required GPUBuffer buffer,
    int? offset,
    int? size
  });

  external GPUBuffer get buffer;
  external int? get offset;
  external int? get size;
}

extension type ShaderDescriptor._(JSObject _) implements JSObject {
  external ShaderDescriptor({
    required String code,
    String? label
  });

  external String get code;
  external String? get label;
}

extension type CanvasConfiguration._(JSObject _) implements JSObject {
  external CanvasConfiguration({
    required GPUDevice device,
    required String format,
    String? alphaMode
  });

  external GPUDevice get device;
  external String get format;
  external String? get alphaMode;
}

extension type RenderPipelineLayout._(JSObject _) implements JSObject {
  external RenderPipelineLayout({
    required GPUPipelineLayout layout,
    required Vertex vertex,
    required Fragment fragment,
    String? label,
    Primitive? primitive
  });

  external GPUPipelineLayout get layout;
  external String? get label;
  external Primitive? get primitive;
  external Vertex get vertex;
  external Fragment get fragment;
}

extension type Primitive._(JSObject _) implements JSObject {
  external Primitive({
    String? topology
  });

  external String? get topology;
}

extension type Vertex._(JSObject _) implements JSObject {
  external Vertex({
    JSAny? constants,
    String? entryPoint,
    JSArray<VertexBuffer>? buffers,
    required GPUShaderModule module
  });

  external JSAny? get constants;
  external String? get entryPoint;
  external GPUShaderModule get module;
  external JSArray<VertexBuffer>? get buffers;
}

extension type VertexBuffer._(JSObject _) implements JSObject {
  external VertexBuffer({
    required int arrayStride,
    required JSArray<VertexAttribute> attributes,
    required String stepMode
  });

  external int get arrayStride;
  external JSArray<VertexAttribute> get attributes;
  external String get stepMode;
}

extension type VertexAttribute._(JSObject _) implements JSObject {
  external VertexAttribute({
    required int shaderLocation,
    required int offset,
    required String format
  });

  external int get shaderLocation;
  external int get offset;
  external String get format;
}

extension type Fragment._(JSObject _) implements JSObject {
  external Fragment({
    JSAny? constants,
    String? entryPoint,
    required GPUShaderModule module,
    required JSArray<FragmentTarget> targets
  });

  external JSAny? get constants;
  external String? get entryPoint;
  external GPUShaderModule get module;
  external JSArray<FragmentTarget> get targets;
}

extension type FragmentTarget._(JSObject _) implements JSObject {
  external FragmentTarget({
    required String format
  });

  external String get format;
}

extension type RenderPassDescriptor._(JSObject _) implements JSObject {
  external RenderPassDescriptor({
    String label,
    required JSArray<ColorAttachment> colorAttachments
  });

  external String? get label;
  external JSArray<ColorAttachment> get colorAttachments;
}

extension type ColorAttachment._(JSObject _) implements JSObject {
  external ColorAttachment({
    required String loadOp,
    required String storeOp,
    required GPUTexture view
  });

  external String get loadOp;
  external String get storeOp;
  external GPUTexture get view;
}