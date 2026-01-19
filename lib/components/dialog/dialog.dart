import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import 'dialog_impl_server.dart' if (dart.library.js_interop) 'dialog_impl_web.dart';

/// An HTML dialog component.
///
/// The dialog is initially hidden and only shown when the value of [open] is
/// set to [true]. When the value of [open] is subsequently set to [false], the
/// dialog is closed (and hence hidden from view).
class Dialog extends CellComponent {
  /// Cell controlling whether the dialog is open (true) or closed (false).
  final MutableCell<bool> open;

  /// Child components displayed in the dialog
  final List<Component> children;

  /// Cell holding the result of the dialog.
  ///
  /// When the dialog is closed via a button in a form with type = "dialog",
  /// this cell is set to the "value" attribute of the button that was pressed.
  final MutableCell<String?>? result;

  /// Additional classes to add to the dialog.
  final String? classes;

  const Dialog(this.children, {
    super.key,
    required this.open,
    this.result,
    this.classes
  });

  @override
  Component build(BuildContext context) => DialogImpl(
      open: open,
      result: result,
      classes: classes,
      children,
  );

  @css
  static List<StyleRule> get styles => [
    css('dialog', [
      css('&').styles(
          border: Border.none,
          width: 30.rem,
          radius: BorderRadius.circular(2.em),
          zIndex: ZIndex(100),
          padding: Padding.all(2.em)
      ),

      css('& .form').styles(
        width: 100.percent
      ),
      css('h1').styles(
        fontSize: 2.em,
      )
    ])
  ];
}