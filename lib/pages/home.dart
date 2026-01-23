import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../components/controls/int_vector_field.dart';
import '../components/controls/num_vector_field.dart';
import '../components/controls/integer_field.dart';
import '../components/controls/slider.dart';
import '../components/dialog/dialog.dart';
import '../components/layout/index.dart';
import '../components/wavesim/index.dart';
import '../simulator/wave_source.dart';
import '../sources/point_source.dart';
import '../util/types.dart';

class Home extends CellComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final simState = MutableCell(
      WavesimState(
        paused: true,
        size: 50
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
          _SizeControl(
              size: state.size
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
          ),
          _WaveSourceControl(
              sources: state.sources,
              size: state.size
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

/// Control for changing the size of the grid
class _SizeControl extends CellComponent {
  /// Cell holding the size of the grid.
  final MutableCell<int> size;

  const _SizeControl({
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final open = MutableCell(false);

    return fragment([
      _SizeDialog(
          open: open,
          size: size
      ),
      CellComponent.builder((_) {
        return label([text('Size: ${size()} \u00D7 ${size()}')]);
      }),
      button(
        onClick: () => open.value = true,
        [
          text('Change')
        ]
      )
    ]);
  }
}

/// Dialog for selecting a size.
class _SizeDialog extends CellComponent {
  /// Cell controlling whether the dialog is open or closed.
  final MutableCell<bool> open;

  /// Cell holding the size selected by the user.
  ///
  /// **NOTE**: The value of this cell is only set if the user, confirms the
  /// entered size.
  final MutableCell<int> size;

  const _SizeDialog({
    required this.open,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final selectedSize = MutableCell(0);
    final result = MutableCell('');

    ValueCell.watch(() {
      if (open()) {
        selectedSize.value = size.peek();
      }
    });

    ValueCell.watch(() {
      if (!open() && result() == 'resize') {
        size.value = selectedSize.peek();
      }
    });

    return Dialog(
        open: open,
        result: result,
        [
          form(method: FormMethod.dialog, [
            Column([
              h1([text('Select Size')]),
              strong([
                text('The current simulation will be reset when the size is changed.')
              ]),
              IntegerField(
                  value: selectedSize,
                  min: 5,
                  max: 1000,

                  title: 'Size'
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, [
                button(
                    autofocus: true,
                    type: ButtonType.button,
                    onClick: () => MutableCell.batch(() {
                      open.value = false;
                    }),

                    [text('Cancel')]
                ),
                button(
                    attributes: {
                      'value': 'resize'
                    },
                    [text('Resize')]
                )
              ])
            ])
          ])
        ]
    );
  }
}

/// A button for adding a wave source to the simulation
class _WaveSourceControl extends CellComponent {
  /// Cell holding the list of sources
  final MutableCell<List<WaveSource>> sources;

  /// Cell holding the size of the simulation grid
  final ValueCell<int> size;

  const _WaveSourceControl({
    required this.sources,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final open = MutableCell(false);

    return fragment([
      _WaveSourceDialog(
        open: open,
        size: size,
        onClose: sources.add,
      ),
      button(
        onClick: () => open.value = true,
        [
          text('Add Wave')
        ]
      )
    ]);
  }
}

/// Dialog for entering the parameters of a wave source
class _WaveSourceDialog extends CellComponent {
  /// Cell controlling whether the dialog is open
  final MutableCell<bool> open;

  /// Cell holding the size of the simulation grid
  final ValueCell<int> size;

  /// Callback called when the add button is clicked.
  ///
  /// The callback is passed the [source] which should be added to the
  /// simulation grid.
  final void Function(WaveSource source) onClose;

  const _WaveSourceDialog({
    required this.open,
    required this.onClose,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final position = MutableCell(
      VectorI(
        x: 0,
        y: 0
      )
    );

    final amplitude = MutableCell(
        VectorF(
            x: 0,
            y: 0
        )
    );

    return Dialog(
      open: open,
      [
        form(method: FormMethod.dialog, [
          Column([
            h1([
              text('Add Wave')
            ]),
            IntVectorField(
                title: 'Position',
                value: position,
                min: VectorI(
                    x: -size(),
                    y: -size()
                ),
                max: VectorI(
                    x: size(),
                    y: size()
                )
            ),
            NumVectorField(
              title: 'Amplitude',
              value: amplitude,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, [
              button(
                  type: ButtonType.button,
                  onClick: () => MutableCell.batch(() {
                    open.value = false;
                  }),

                  [text('Cancel')]
              ),
              button(
                  autofocus: true,
                  onClick: () => onClose(
                      PointPulse(
                          position: position.value,
                          amplitude: amplitude.value
                      )
                  ),

                  [text('Add')]
              )
            ])
          ])
        ])
      ]
    );
  }
}