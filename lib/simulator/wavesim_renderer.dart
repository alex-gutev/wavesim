import '../webgpu/index.dart';

/// Represents a size
class Size {
  final int width;
  final int height;

  int get area => width * height;

  const Size({
    required this.width,
    required this.height
  });
}

/// Interface for rendering a visual representation of the simulation state
abstract interface class WavesimRenderer {
  /// Initialize the renderer.
  ///
  /// [gridSize] is the size of the entire grid, while [visibleSize] is the
  /// size of the visible portion of the grid.
  ///
  /// [sizeBuffer] is a buffer holding the size of the grid.
  ///
  /// [heatmap] and [maxHeat] are the buffers into which the heatmap and maximum
  /// heat are written.
  void init({
    required Size gridSize,
    required Size visibleSize,
    required GPUBuffer sizeBuffer,
    required GPUBuffer heatmap,
    required GPUBuffer maxHeat
  });

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