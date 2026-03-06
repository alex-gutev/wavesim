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

  /// The amplitude of the curl. If positive, the wave curls clockwise,
  /// otherwise the wave curls anti-clockwise.
  final double amplitude;

  CurlSource({
    required this.center,
    required this.amplitude,
    super.frequency = 0,
    super.maxSteps
  });

  @override
  bool update(WavesimEngine2D engine) {
    final a = scale * amplitude;

    engine.displace(
        x: center.x + 1,
        y: center.y,
        dx: 0,
        dy: -a
    );

    engine.displace(
        x: center.x - 1,
        y: center.y,
        dx: 0,
        dy: a
    );

    engine.displace(
        x: center.x,
        y: center.y + 1,
        dx: a,
        dy: 0
    );

    engine.displace(
        x: center.x,
        y: center.y - 1,
        dx: -a,
        dy: 0
    );

    return super.update(engine);
  }

  @override
  String describe() => 'Curl (${center.x}, ${center.y})';
}