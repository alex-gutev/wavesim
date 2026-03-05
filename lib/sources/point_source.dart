import 'package:live_cells_core/live_cells_core.dart';

import 'alternating_source.dart';
import '../simulator/wavesim_engine_2d.dart';
import '../util/types.dart';

part 'point_source.g.dart';

/// A wave source emanating from a single point.
///
/// This source creates a wave emanating from a give [position] with a given
/// [amplitude].
@CellExtension(mutable: true)
class PointSource extends AlternatingSource {
  /// Position at which to create the pulse
  final Vector<int> position;

  /// Amplitude of the pulse
  final Vector<double> amplitude;

  PointSource({
    required this.position,
    required this.amplitude,
    super.maxSteps,
    super.frequency = 0
  });

  @override
  bool update(WavesimEngine2D engine) {
    final f = scale;

    engine.displace(
        x: position.x,
        y: position.y,
        dx: f * amplitude.x,
        dy: f * amplitude.y
    );

    return super.update(engine);
  }
}