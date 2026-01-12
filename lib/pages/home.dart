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

    final clear = ActionCell();

    return section([
      Row(crossAxisAlignment: CrossAxisAlignment.stretch, [
        WavesimCanvas(
          state: simState,
          clear: clear
        ),
        WavesimControls(
            state: simState,
            clear: clear
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

  /// Action cell for clearing the simulation
  final ActionCell clear;

  const WavesimControls({
    required this.state,
    required this.clear
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
          ),
          _ClearButton(
              clear: clear
          ),
          _GraphicsControls(
              graphics: state.graphics
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

/// A button for clearing the simulation
class _ClearButton extends StatelessComponent {
  /// Action cell for clearing the simulation
  final ActionCell clear;

  const _ClearButton({required this.clear});

  @override
  Component build(BuildContext context) => button(
    onClick: clear.trigger,
    [
      text('Clear')
    ]
  );
}

/// Controls for selecting the type of graphics rendering to use for the simulation.
class _GraphicsControls extends CellComponent {
  final MutableCell<WavesimGraphics> graphics;

  const _GraphicsControls({required this.graphics});

  @override
  Component build(BuildContext context) => fragment([
    label([text('Graphics')]),
    label([
      input(
        type: InputType.radio,
        name: 'wavesim-graphics',
        value: WavesimGraphics.blocks.name,

        onChange: (e) {
          graphics.value = WavesimGraphics.blocks;
        },

        checked: graphics.value == WavesimGraphics.blocks
      ),
      text('Blocks')
    ]),
    label([
      input(
          type: InputType.radio,
          name: 'wavesim-graphics',
          value: WavesimGraphics.heatmap.name,

          onChange: (e) {
            graphics.value = WavesimGraphics.heatmap;
          },

          checked: graphics.value == WavesimGraphics.heatmap
      ),
      text('Heatmap')
    ])
  ]);
}