import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';

/// A form that triggers a [submit] cell when submitted.
class Form extends StatelessComponent {
  /// Cell to trigger when the form is submitted
  final ActionCell submit;

  /// Form elements
  final List<Component> children;

  /// Form submission method
  final FormMethod? method;

  const Form(this.children, {
    super.key,
    required this.submit,
    this.method
  });

  @override
  Component build(BuildContext context) => form(
      method: method,
      events: {
        'submit': (e) => submit.trigger()
      },
      children
  );
}