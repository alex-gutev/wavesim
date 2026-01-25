import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/slider.dart';

/// A slider for controlling the simulation speed
class SpeedControl extends CellComponent {
  /// Cell holding the delay between frames.
  ///
  /// The value of this cell is updated to reflect the user's choice.
  final MutableCell<Duration> frameDelay;

  const SpeedControl({
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
