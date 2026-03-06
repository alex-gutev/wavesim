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
    super.maxSteps,
    required this.start,
    required this.end,
    required this.amplitude
  });

  @override
  bool update(WavesimEngine2D engine) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;

    final m = dy / dx;

    var curY = start.y;

    print('(${start.x}, ${start.y}) - (${end.x}, ${end.y}) ($m)');

    for (var x = start.x; x <= end.x; x++) {
      final endY = (curY+m).ceil();

      for (var y = curY; y <= endY; y++) {
        engine.displace(
            x: x,
            y: y,
            dx: scale * amplitude.x,
            dy: scale * amplitude.y
        );
      }

      curY = endY;
    }

    return super.update(engine);
  }

  @override
  String describe() => 'Line (${start.x}, ${start.y}) - '
      '(${end.x}, ${end.y})';
}