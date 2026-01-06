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
abstract interface class WavesimRender {
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