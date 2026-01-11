import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../components/controls/slider.dart';
import '../components/layout/index.dart';
import '../components/wavesim/index.dart';

class Home extends CellComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final simState = MutableCell(
      WavesimState(
        paused: true,
      )
    );

    return section([
      Row(crossAxisAlignment: CrossAxisAlignment.stretch, [
        WavesimCanvas(
            state: simState
        ),
        WavesimControls(
            state: simState
        )
      ])
    ]);
  }
}

/// Provides controls for changing the simulation settings.
class WavesimControls extends CellComponent {
  /// Cell holding the simulation state.
  ///
  /// When the user changes a setting, the value of the cell is updated to
  /// reflect the changes.
  final MutableCell<WavesimState> state;

  const WavesimControls({
    required this.state
  });

  @override
  Component build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        [
          button(
              onClick: () => state.paused.value = !state.paused.value,
              [
                text(
                    state.paused() ? 'Run' : 'Pause'
                )
              ]
          ),
          _SpeedControl(
              frameDelay: state.frameDelay
          ),
          _WaveSpeedControl(
              speed: state.c
          )
        ]
    );
  }
}

/// A slider for controlling the simulation speed
class _SpeedControl extends CellComponent {
  /// Cell holding the delay between frames.
  ///
  /// The value of this cell is updated to reflect the user's choice.
  final MutableCell<Duration> frameDelay;

  const _SpeedControl({
    required this.frameDelay
  });

  @override
  Component build(BuildContext context) {
    final delay = frameDelay.inMilliseconds;

    final speed = MutableCell.computed(() => 100 - delay(), (inv) {
      delay.value = 100 - inv;
    });

    return fragment([
      label([text('Simulation Speed')]),
      Slider(
          min: 0,
          max: 100,
          step: 10,
          value: speed
      ),
    ]);
  }
}

/// A slider for controlling the wave speed
class _WaveSpeedControl extends CellComponent {
  /// Cell holding the wave speed.
  ///
  /// The value of this cell is updated to reflect the user's choice.
  final MutableCell<double> speed;

  const _WaveSpeedControl({
    required this.speed
  });

  @override
  Component build(BuildContext context) {
    return fragment([
      label([text('Wave Speed (${speed()})')]),
      Slider(
          min: 0.1,
          step: 0.01,
          max: 1.0,
          value: speed
      ),
    ]);
  }
}