import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import 'boundary_control.dart';
import '../../components/icon.dart';
import '../../constants/icons.dart';
import '../../components/layout/index.dart';
import '../../components/wavesim/index.dart';
import 'graphics_control.dart';
import 'size_control.dart';
import 'speed_control.dart';
import 'wave_speed_control.dart';

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
          _RunButton(
              paused: state.paused
          ),
          SizeControl(
              size: state.size
          ),
          SpeedControl(
              frameDelay: state.frameDelay
          ),
          WaveSpeedControl(
              speed: state.c
          ),
          BoundaryControl(
              closed: state.closed
          ),
          _ClearButton(
              clear: clear
          ),
          GraphicsControls(
              graphics: state.graphics
          ),
        ]
    );
  }
}

/// Button for starting and pausing simulation
class _RunButton extends CellComponent {
  final MutableCell<bool> paused;

  const _RunButton({
    required this.paused
  });

  @override
  Component build(BuildContext context) => button(
      onClick: () => paused.value = !paused.value,
      [
        if (paused())
          Icon(
            src: Icons.run,
            label: 'Run',
            mainAxisAlignment: MainAxisAlignment.center
          )
        else
          Icon(
            src: Icons.pause,
            label: 'Pause',
            mainAxisAlignment: MainAxisAlignment.center
          )
      ]
  );
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
        Icon(
          src: Icons.clear,
          label: 'Clear',
          mainAxisAlignment: MainAxisAlignment.center
        )
      ]
  );
}