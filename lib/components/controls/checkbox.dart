import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../layout/index.dart';

/// A checkbox input field
class Checkbox extends CellComponent {
  /// Cell holding the state of the checkbox
  ///
  /// This cell holds the value true when the checkbox is checked
  /// and false when it is not checked.
  ///
  /// When the value of this cell is changed, the state of the checkbox
  /// field is updated to reflect the value of the cell. Likewise, when the
  /// state of the checkbox changes, the value of this cell is updated to
  /// reflect the change.
  final MutableCell<bool> checked;

  /// A component to add before the checkbox.
  final Component? leading;

  /// A component to add after the checkbox.
  final Component? trailing;

  /// Should this field be enabled for user input?
  final bool enabled;

  const Checkbox({
    super.key,
    required this.checked,
    this.leading,
    this.trailing,
    this.enabled = true
  });

  @override
  Component build(BuildContext context) => label([
    Row([
      if (leading != null)
        Expanded(leading!),

      input(
          type: InputType.checkbox,
          checked: checked(),
          disabled: !enabled,
          onChange: (newState) => checked.value = newState
      ),

      if (trailing != null)
        Expanded(trailing!)
    ])
  ]);
}