import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import 'field.dart';

/// A field for entering integer values.
///
/// This field takes care of parsing an integer value from the content entered
/// in a text input field, and displaying an error message when invalid data
/// is entered.
class IntegerField extends CellComponent {
  /// Cell holding the value entered in the field.
  ///
  /// When the value of this cell is changed, the content of the field is
  /// updated to reflect the value. Likewise, when the content of the field
  /// is changed, the value entered of this cell is updated to reflect the
  /// content.
  final MutableCell<int> value;

  /// Optional label to show above the field.
  final String? title;

  /// The minimum permitted value
  final int min;

  /// The maximum permitted value
  final int max;

  /// The step between allowed values.
  final int step;

  const IntegerField({
    super.key,
    this.title,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1
  });

  @override
  Component build(BuildContext context) {
    final maybe = value.maybe();

    return Field(
        title: title,
        value: maybe.mutableString(),
        type: FieldType.number,

        error: maybe.error() != null || (value() < min) || (value() > max)
            ? 'Please enter a valid integer between $min and $max'
            : null,

        attributes: {
          'min': min.toString(),
          'max': max.toString(),
          'step': step.toString()
        }
    );
  }
}