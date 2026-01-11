import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

/// A slider component for selecting a numeric [value] in a given range.
///
/// [min] is the minimum value of the allowed range while [max] is the maximum
/// value. If [step] is not null, the user can only select values that are
/// multiples of [step].
///
/// [value] is the cell holding the selected value. When the value of the cell
/// is changed, the position of the slider is updated to reflect the value of
/// the cell. Similarly, when the position of the slider is changed by the user
/// the value of the cell is updated to reflect the selected value.
class Slider extends CellComponent {
  /// The minimum value that can be selected.
  final num min;

  /// The maximum value that can be selected.
  final num max;

  /// The step between selected values.
  final num? step;

  /// Cell holding the selected value.
  final MutableCell<num> value;

  /// Should the component be enabled for user input?
  final bool enabled;

  const Slider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    this.step,
    this.enabled = true
  });

  @override
  Component build(BuildContext context) {
    return input(
      type: InputType.range,
      value: value().toString(),
      disabled: !enabled,

      attributes: {
        'min': min.toString(),
        'max': max.toString(),

        if (step != null)
          'step': step.toString()
      },

      onInput: (newValue) =>
        value.value = num.parse(newValue)
    );
  }
}