import 'package:wavesim/sources/circle_pulse.dart';
import 'package:wavesim/util/types.dart';

import '../simulator/wave_source.dart';
import '../simulator/wavesim_engine_2d.dart';

class CircleStandingWave implements WaveSource {
  /// The position of the center of the circle
  final VectorI center;

  /// The radius of the circle
  final int radius;

  /// The strength of the pulse
  final double amplitude;

  const CircleStandingWave({
    required this.center,
    required this.radius,
    required this.amplitude
  });

  @override
  bool update(WavesimEngine2D engine) {
    final pulses = List.generate(radius, (r) => CirclePulse(
        center: center,
        radius: r+1,
        amplitude: amplitude * ((r % 2) == 0 ? 1 : -1)
    ));

    for (final pulse in pulses) {
      pulse.update(engine);
    }

    return false;
  }
}