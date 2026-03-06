import 'package:wavesim/simulator/wavesim_engine_2d.dart';

/// Interface for a wave source.
///
/// This interface allows the state of a wave simulator to be modified
/// in a controller manner. The [update] method is called just before the state
/// of the simulator is updated at each time step.
abstract class WaveSource {
  /// Update the wave source.
  ///
  /// Implementations of this method should update the state of the wave
  /// source using the provided simulator [engine].
  ///
  /// The return value indicates whether the source should be kept or removed.
  /// If true is returned, the source is kept and [update] is called again
  /// before the next time step. If false is returned, the source is removed
  /// and [update] is never called again.
  bool update(WavesimEngine2D engine);

  /// Returns a string that describes this wave source.
  String describe();

  @override
  String toString() => describe();
}