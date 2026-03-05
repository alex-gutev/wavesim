import 'dart:math';

import 'package:live_cells_core/live_cells_core.dart';

import 'alternating_source.dart';
import '../simulator/wavesim_engine_2d.dart';
import '../util/types.dart';

part 'circle_source.g.dart';

/// A wave source emanating from the perimeter of a circle
///
/// The source creates a wave emanating from the perimeter of the circle with a
/// given [center] and [radius].
///
/// [amplitude] is the strength of the wave at the circle. If positive, the
/// wave points away from the center of the circle. If negative the wave points
/// towards the center of the circle
@CellExtension(mutable: true)
class CircleSource extends AlternatingSource {
  /// The position of the center of the circle
  final VectorI center;

  /// The radius of the circle
  final int radius;

  /// The strength of the pulse
  final double amplitude;

  CircleSource({
    required this.center,
    required this.radius,
    required this.amplitude,
    super.maxSteps,
    super.frequency = 0
  });

  @override
  bool update(WavesimEngine2D engine) {
    assert(radius > 0);

    // TODO: Cut off points that fall outside the grid

    final numPoints = (2 * pi * radius).ceil();
    final tDelta = 2 * pi / numPoints;

    final a = amplitude * scale;

    for (var i = 0; i < numPoints; i++) {
      final theta = i * tDelta;
      final x = cos(theta);
      final y = sin(theta);

      engine.displace(
          x: center.x + (x * radius).round(),
          y: center.y + (y * radius).round(),
          dx: a * x,
          dy: a * y
      );
    }

    return super.update(engine);
  }
}