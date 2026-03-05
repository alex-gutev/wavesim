import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

/// Signature of [Select] option component builder callback.
///
/// Functions of this type are passed the build [context] and the [option]
/// for which to build the component.
typedef OptionBuilder<T> =
  Component Function(BuildContext context, T option);

/// A control for selecting an option out of a dropdown list of [options].
///
/// [options] is the list of options, from which the user may select. These
/// are rendered as a drop down list. [builder] is called to build the
/// user facing component for each option in [options].
///
/// The cell [selected] holds the option selected by the user. Changing the
/// value of this cell, changes the selected option. Similarly, when an option
/// is selected by the user the value of this cell is updated to reflect the
/// change.
///
/// **NOTE**: [T] should provide sensible implementations of the  [==] and
/// [hashCode] methods.
class Select<T extends Object> extends CellComponent {
  /// List of options from which the user may select
  final List<T> options;

  /// Cell holding the selected option
  final MutableCell<T> selected;

  /// Option component callback function
  final OptionBuilder<T> builder;

  /// Optional title to display above the control
  final String? title;

  const Select({
    super.key,
    required this.options,
    required this.selected,
    required this.builder,
    this.title
  });

  @override
  Component build(BuildContext context) => label([
    div(classes: 'field', [
      if (title != null)
        span([
          text(title!)
        ]),
      select(
          onChange: (selection) {
            selected.value = options[int.parse(selection.first)];
          },

          List.generate(options.length, (i) => option(
              selected: options[i] == selected(),
              value: i.toString(),
              [
                builder(context, options[i])
              ]
          ))
      )
    ])
  ]);
}