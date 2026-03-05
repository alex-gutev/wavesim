import 'dart:math';

import 'package:live_cells_core/live_cells_core.dart';

import '../simulator/wavesim_engine_2d.dart';
import '../simulator/wave_source.dart';
import '../util/types.dart';

part 'point_source.g.dart';

/// A wave source emanating from a single point.
///
/// This source creates a wave emanating from a give [position], within the
/// simulation grid, with a given [amplitude]. The pulse is only created for
/// one time step after which the source is removed.
@CellExtension(mutable: true)
class PointSource implements WaveSource {
  /// Position at which to create the pulse
  final Vector<int> position;

  /// Amplitude of the pulse
  final Vector<double> amplitude;

  /// Frequency of the wave
  final double frequency;

  /// The maximum number of time steps for which the source should be kept.
  ///
  /// If null the source is kept indefinitely. If null, the source is only kept
  /// for this number of time steps.
  final int? maxSteps;

  PointSource({
    required this.position,
    required this.amplitude,
    this.maxSteps,
    this.frequency = 0
  });

  @override
  bool update(WavesimEngine2D engine) {
    final f = cos(pi * frequency * _time / 10);

    engine.displace(
        x: position.x,
        y: position.y,
        dx: f * amplitude.x,
        dy: f * amplitude.y
    );

    _time++;

    return maxSteps != null
        ? _time < maxSteps!
        : true;
  }

  var _time = 0;
}