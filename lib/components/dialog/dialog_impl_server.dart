import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';

/// Implementation of [Dialog] component for the server environment.
///
/// This implementation does not provide any functionality for opening and
/// closing the dialog.
class DialogImpl extends StatelessComponent {
  final MutableCell<bool> open;
  final List<Component> children;
  final MutableCell<String?>? result;
  final String? classes;

  const DialogImpl(this.children, {
    super.key,
    required this.open,
    required this.result,
    required this.classes
  });

  @override
  Component build(BuildContext context) => dialog(
      classes: classes,
      children
  );
}