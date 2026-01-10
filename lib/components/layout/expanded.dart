import 'package:jaspr/jaspr.dart';

/// A [Component] that expands to fill the available space of a [Row] or [Column].
class Expanded extends StatelessComponent {
  /// The child component to insert underneath this component.
  final Component child;

  const Expanded(this.child, {
    super.key
  });

  @override
  Component build(BuildContext context) {
    return Component.wrapElement(
        classes: 'flex-item-expanded',
        child: child
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.flex-item-expanded').styles(
      flex: Flex.auto
    )
  ];
}