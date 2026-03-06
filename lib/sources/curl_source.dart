import 'dart:math';

import 'package:live_cells_core/live_cells_core.dart';

import '../util/types.dart';
import 'alternating_source.dart';
import '../simulator/wavesim_engine_2d.dart';

part 'curl_source.g.dart';

/// Creates a wave that curls around a [center].
@CellExtension(mutable: true)
class CurlSource extends AlternatingSource {
  /// The center around which the wave curls
  final VectorI center;

  /// The radius of the curl around the [center].
  final int radius;

  /// The amplitude of the curl. If positive, the wave curls clockwise,
  /// otherwise the wave curls anti-clockwise.
  final double amplitude;

  CurlSource({
    required this.center,
    required this.radius,
    required this.amplitude,
    super.frequency = 0,
    super.maxSteps
  });

  @override
  bool update(WavesimEngine2D engine) {
    final a = scale * amplitude;

    for (var py = -radius-1; py < radius+1; py++) {
      for (var px = -radius-1; px < radius+1; px++) {
        if ((py*py + px*px) < radius*radius) {
          final theta = atan2(py, px);

          final c = cos(theta);
          final s = sin(theta);

          engine.displace(
              x: center.x + px,
              y: center.y + py,
              dx: -a * s,
              dy: a * c
          );
        }
      }
    }

    return super.update(engine);
  }

  @override
  String describe() => 'Curl ($frequency Hz)';
}