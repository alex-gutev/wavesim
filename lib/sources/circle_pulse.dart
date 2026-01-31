import 'dart:math';

import '../simulator/wave_source.dart';
import '../simulator/wavesim_engine_2d.dart';
import '../util/types.dart';

/// A wave source that creates a pulse at the perimeter of a circle
///
/// The pulse is created at the perimeter of the circle with a given [center]
/// and [radius].
///
/// [amplitude] is the strength of the pulse. If positive, the pulse points
/// away from the center of the circle. If negative the pulse points towards
/// the center of the circle
class CirclePulse implements WaveSource {
  /// The position of the center of the circle
  final VectorI center;

  /// The radius of the circle
  final int radius;

  /// The strength of the pulse
  final double amplitude;

  const CirclePulse({
    required this.center,
    required this.radius,
    required this.amplitude
  });

  @override
  bool update(WavesimEngine2D engine) {
    assert(radius > 0);

    // TODO: Cut off points that fall outside the grid

    final numPoints = (2 * pi * radius).ceil();
    final tDelta = 2 * pi / numPoints;

    for (var i = 0; i < numPoints; i++) {
      final theta = i * tDelta;
      final x = cos(theta);
      final y = sin(theta);

      engine.displace(
          x: center.x + (x * radius).round(),
          y: center.y + (y * radius).round(),
          dx: amplitude * x,
          dy: amplitude * y
      );
    }

    return false;
  }
}