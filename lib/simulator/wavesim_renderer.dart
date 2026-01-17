import '../webgpu/index.dart';

/// Interface for rendering a visual representation of the simulation state
abstract interface class WavesimRenderer {
  /// Initialize the renderer.
  ///
  /// [size] is the size of the grid.
  /// [sizeBuffer] is a buffer holding the size of the grid.
  ///
  /// [heatmap] and [maxHeat] are the buffers into which the heatmap and maximum
  /// heat are written.
  void init({
    required int size,
    required GPUBuffer sizeBuffer,
    required GPUBuffer heatmap,
    required GPUBuffer maxHeat
  });

  /// Dispose resources acquired during [init].
  ///
  /// When this method is called, the renderer will no longer be used.
  /// Buffers and other GPU objects created during [init] should be disposed
  /// during this method.
  void dispose();

  /// Render a visual representation of the simulation state.
  ///
  /// [data] is the buffer holding the current simulation state. Implementations
  /// of this method should add rendering commands to [encoder] that render
  /// a visual representation of [data].
  void render({
    required GPUCommandEncoder encoder,
    required GPUBuffer data
  });
}