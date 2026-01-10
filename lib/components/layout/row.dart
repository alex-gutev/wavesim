import 'package:jaspr/jaspr.dart';

import 'alignment.dart';

/// A container that lays out [children] components horizontally in a row.
class Row extends StatelessComponent {
  /// The child components to lay out
  final List<Component> children;

  /// The alignment of the child components along the cross (vertical) axis.
  final CrossAxisAlignment? crossAxisAlignment;

  /// The alignment of the child components along the main (horizontal) axis.
  final MainAxisAlignment? mainAxisAlignment;

  /// Additional classes to add to the component
  final String? classes;

  const Row(this.children, {
    super.key,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.classes
  });

  @override
  Component build(BuildContext context) => div(
      classes: _classes.join(' '),
      children
  );


  List<String> get _classes => [
    'row',

    if (crossAxisAlignment != null)
      crossAxisAlignment!.cssClass,

    if (mainAxisAlignment != null)
      mainAxisAlignment!.cssClass,

    if (classes != null)
      classes!
  ];

  @css
  static List<StyleRule> get styles => [
    css('.row').styles(
      display: Display.flex,
      flexDirection: FlexDirection.row,
      gap: Gap.all(10.px)
    )
  ];
}