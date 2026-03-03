import '../webgpu/index.dart';

/// Simulation state buffers
class SimBuffer {
  /// The first buffer
  final GPUBuffer buffer1;

  /// The second buffer
  final GPUBuffer buffer2;

  /// The buffer holding the current simulation state
  GPUBuffer get current => _firstBuf ? buffer1 : buffer2;

  /// The buffer holding the previous simulation state.
  ///
  /// This is also the buffer where the next simulation state is written to.
  GPUBuffer get previous => _firstBuf ? buffer2 : buffer1;

  /// Is the first buffer [buffer1] the current buffer?
  bool get isFirst => _firstBuf;

  SimBuffer({
    required this.buffer1,
    required this.buffer2
  });

  /// Dispose all simulation state buffers
  void dispose() {
    buffer1.destroy();
    buffer2.destroy();
  }

  /// Clear the contents of the buffers.
  ///
  /// Commands for clearing the buffers contents are added to the given
  /// command [encoder].
  void clear(GPUCommandEncoder encoder) {
    encoder.clearBuffer(buffer1);
    encoder.clearBuffer(buffer2);

    _firstBuf = true;
  }

  /// Swap the previous and current state buffers.
  void swap() {
    _firstBuf = !_firstBuf;
  }

  /// Is [buffer1] the current buffer?
  var _firstBuf = true;
}