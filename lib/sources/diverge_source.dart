import 'package:live_cells_core/live_cells_core.dart';

import 'alternating_source.dart';
import '../util/types.dart';
import '../simulator/wavesim_engine_2d.dart';

part 'diverge_source.g.dart';

/// Creates a divergence source at a given [center].
///
/// This source creates a wave that diverges from [center], when [amplitude] is
/// positive. When [amplitude] is negative, the wave source converges towards
/// center
@CellExtension(mutable: true)
class DivergeSource extends AlternatingSource {
  /// The center of divergence/convergence.
  final VectorI center;

  /// The amplitude of the divergence.
  ///
  /// If negative, a convergence is created.
  final double amplitude;

  DivergeSource({
    super.frequency = 0,
    super.maxSteps,
    required this.center,
    required this.amplitude
  });

  @override
  bool update(WavesimEngine2D engine) {
    final a = scale(engine) * amplitude;

    engine.displace(
        x: center.x,
        y: center.y-1,
        dx: 0,
        dy: -a
    );

    engine.displace(
        x: center.x,
        y: center.y+1,
        dx: 0,
        dy: a
    );

    engine.displace(
        x: center.x-1,
        y: center.y,
        dx: -a,
        dy: 0
    );

    engine.displace(
        x: center.x+1,
        y: center.y,
        dx: a,
        dy: 0
    );

    return super.update(engine);
  }

  @override
  String describe() => 'Divergence (${center.x}, ${center.y})';
}