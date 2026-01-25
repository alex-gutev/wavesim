import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/slider.dart';

/// A slider for controlling the wave speed
class WaveSpeedControl extends CellComponent {
  /// Cell holding the wave speed.
  ///
  /// The value of this cell is updated to reflect the user's choice.
  final MutableCell<double> speed;

  const WaveSpeedControl({
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
