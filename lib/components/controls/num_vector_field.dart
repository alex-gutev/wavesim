import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import 'num_field.dart';
import '../layout/index.dart';
import '../../util/types.dart';

/// A field for entering a numeric (decimal) vector.
///
/// This field takes care of parsing the value, and displaying an error message
/// when invalid data is entered.
class NumVectorField extends CellComponent {
  /// Cell holding the value entered in the field.
  ///
  /// When the value of this cell is changed, the content of the field is
  /// updated to reflect the value. Likewise, when the content of the field
  /// is changed, the value entered of this cell is updated to reflect the
  /// content.
  final MutableCell<VectorF> value;

  /// Optional label to show above the field.
  final String? title;

  /// The minimum permitted value
  final VectorF? min;

  /// The maximum permitted value
  final VectorF? max;

  /// The step between allowed values.
  final VectorF? step;

  const NumVectorField({
    super.key,
    this.title,
    required this.value,
    this.min,
    this.max,
    this.step
  });

  @override
  Component build(BuildContext context) {
    return Column([
      if (title != null)
        label([
          text(title!)
        ]),
      div(classes: 'vector-field', [
        NumField(
            value: value.x,
            min: min?.x,
            max: max?.x,
            step: step?.x,

            title: 'X'
        ),
        NumField(
            value: value.y,
            min: min?.y,
            max: max?.y,
            step: step?.y,

            title: 'Y'
        )
      ])
    ]);
  }
}