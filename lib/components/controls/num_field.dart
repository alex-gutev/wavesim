import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import 'field.dart';

/// A field for entering numeric (decimal) values.
///
/// This field takes care of parsing a numeric value from the content entered
/// in a text input field, and displaying an error message when invalid data
/// is entered.
class NumField extends CellComponent {
  /// Cell holding the value entered in the field.
  ///
  /// When the value of this cell is changed, the content of the field is
  /// updated to reflect the value. Likewise, when the content of the field
  /// is changed, the value entered of this cell is updated to reflect the
  /// content.
  final MutableCell<num> value;

  /// Optional label to show above the field.
  final String? title;

  /// The minimum permitted value
  final num? min;

  /// The maximum permitted value
  final num? max;

  /// The step between allowed values.
  final num? step;
  /// Is this a required field?
  ///
  /// If true a required field marker is shown next to the [title] (provided
  /// it is not null). The required HTML attribute is set to true and an error
  /// message is shown if the field is left empty.
  final bool required;

  /// Is this field enabled for input?
  final bool enabled;

  const NumField({
    super.key,
    this.title,
    required this.value,
    this.min,
    this.max,
    this.step = 0.01,
    this.required = false,
    this.enabled = true
  });

  @override
  Component build(BuildContext context) {
    final maybe = value.maybe();

    return Field(
        title: title,
        value: maybe.mutableString(),
        type: FieldType.number,
        required: required,
        enabled: enabled,

        validate: (context) {
          if (maybe.error() != null ||
              (min != null && value() < min!) ||
              (max != null && value() > max!) ||
              !value().isFinite) {
            return _errorMessage();
          }

          return '';
        },

        attributes: {
          if (min != null)
            'min': min.toString(),

          if (max != null)
            'max': max.toString(),

          if (step != null)
            'step': step.toString()
        }
    );
  }

  String _errorMessage() {
    if (min != null) {
      if (max != null) {
        return 'Please enter a valid number between $min and $max';
      }

      return 'Please enter a valid number greater than or equal to $min';
    }
    else if (max != null) {
      return 'Please enter a valid number less than or equal to $max';
    }

    return 'Please enter a valid number';
  }
}