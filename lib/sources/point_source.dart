import 'package:wavesim/simulator/wavesim_engine_2d.dart';
import 'package:wavesim/util/types.dart';

import '../simulator/wave_source.dart';

/// A wave source that creates a point at a single [position].
///
/// This source creates a single pulse at a given [position], within the
/// simulation grid, with a given [amplitude]. The pulse is only created for
/// one time step after which the source is removed.
class PointPulse implements WaveSource {
  /// Position at which to create the pulse
  final Vector<int> position;

  /// Amplitude of the pulse
  final Vector<double> amplitude;

  const PointPulse({
    required this.position,
    required this.amplitude
  });

  @override
  bool update(WavesimEngine2D engine) {
    engine.displace(
        x: position.x,
        y: position.y,
        dx: amplitude.x,
        dy: amplitude.y
    );

    return false;
  }
}