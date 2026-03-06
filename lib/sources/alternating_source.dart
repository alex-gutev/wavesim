import 'dart:math';

import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:wavesim/simulator/wave_source.dart';

import '../simulator/wavesim_engine_2d.dart';

part 'alternating_source.g.dart';

/// Base class for a source with an alternating amplitude.
///
/// The amplitude alternates with the given [frequency]. This class can also
/// be used to create a source that is only kept for a given number of timesteps,
/// which is given by [maxSteps].
@CellExtension()
abstract class AlternatingSource extends WaveSource {
  /// Frequency of the wave
  final double frequency;

  /// The maximum number of time steps for which the source should be kept.
  ///
  /// If null the source is kept indefinitely. If null, the source is only kept
  /// for this number of time steps.
  final int? maxSteps;

  /// The scale by which to multiply the amplitude at the current time.
  double get scale => cos(pi * frequency * _time / 10);

  AlternatingSource({
    required this.frequency,
    required this.maxSteps
  });

  @override
  @mustCallSuper
  bool update(WavesimEngine2D engine) {
    _time++;

    return maxSteps != null
        ? _time < maxSteps!
        : true;
  }

  var _time = 0;
}