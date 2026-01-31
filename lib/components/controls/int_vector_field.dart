import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../layout/index.dart';
import '../../util/types.dart';
import 'integer_field.dart';

/// A field for entering an integer vector.
///
/// This field takes care of parsing the value, and displaying an error message
/// when invalid data is entered.
class IntVectorField extends CellComponent {
  /// Cell holding the value entered in the field.
  ///
  /// When the value of this cell is changed, the content of the field is
  /// updated to reflect the value. Likewise, when the content of the field
  /// is changed, the value entered of this cell is updated to reflect the
  /// content.
  final MutableCell<VectorI> value;

  /// Optional label to show above the field.
  final String? title;

  /// The minimum permitted value
  final VectorI min;

  /// The maximum permitted value
  final VectorI max;

  /// The step between allowed values.
  final VectorI step;

  /// Is this a required field?
  ///
  /// If true a required field marker is shown next to the [title] of the fields
  /// for the X and Y components, the required HTML attribute is set to true and
  /// an error message is shown if the fields are left empty.
  final bool required;

  const IntVectorField({
    super.key,
    this.title,
    required this.value,
    required this.min,
    required this.max,
    this.step = const VectorI(x: 1, y: 1),
    this.required = false
  });

  @override
  Component build(BuildContext context) {
    return Column([
      if (title != null)
        label([
          text(title!)
        ]),
      div(classes: 'vector-field', [
        IntegerField(
            value: value.x,
            min: min.x,
            max: max.x,
            step: step.x,
            required: required,

            title: 'X'
        ),
        IntegerField(
            value: value.y,
            min: min.y,
            max: max.y,
            step: step.y,
            required: required,

            title: 'Y'
        )
      ])
    ]);
  }
}