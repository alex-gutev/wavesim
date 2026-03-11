import 'dart:math';

import 'package:live_cells_core/live_cells_core.dart';

import 'alternating_source.dart';
import '../util/types.dart';
import '../simulator/wavesim_engine_2d.dart';

part 'line_source.g.dart';

/// A wave source that emanates from a line.
@CellExtension(mutable: true)
class LineSource extends AlternatingSource {
  /// Starting point of the line
  final VectorI start;

  /// Ending point of the line
  final VectorI end;

  /// Amplitude of the wave.
  final VectorF amplitude;

  LineSource({
    super.frequency = 0,
    super.phase = 0,
    super.maxSteps,
    required this.start,
    required this.end,
    required this.amplitude
  });

  @override
  bool update(WavesimEngine2D engine) {
    final d = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2)).ceil();

    final s = scale(engine);
    final ax = s * amplitude.x;
    final ay = s * amplitude.y;

    if (d > 0) {
      final dx = (end.x - start.x) / d;
      final dy = (end.y - start.y) / d;

      var x = start.x.toDouble();
      var y = start.y.toDouble();

      for (var i = 0; i < d; i++) {
        engine.displace(
            x: x.round(),
            y: y.round(),
            dx: ax,
            dy: ay
        );

        x += dx;
        y += dy;
      }
    }

    return super.update(engine);
  }

  @override
  String describe() => 'Line (${start.x}, ${start.y}) - '
      '(${end.x}, ${end.y})';
}