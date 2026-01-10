import 'package:jaspr/jaspr.dart';
import 'alignment.dart';

/// A container that lays out [children] components vertically in a column.
class Column extends StatelessComponent {
  /// The child components to lay out
  final List<Component> children;

  /// The alignment of the child components along the cross (horizontal) axis.
  final CrossAxisAlignment? crossAxisAlignment;

  /// The alignment of the child components along the main (vertical) axis.
  final MainAxisAlignment? mainAxisAlignment;

  /// Additional classes to add to the component
  final String? classes;

  const Column(this.children, {
    super.key,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.classes
  });

  @override
  Component build(BuildContext context) => div(
    children,
    classes: _classes.join(' ')
  );

  List<String> get _classes => [
    'column',

    if (crossAxisAlignment != null)
      crossAxisAlignment!.cssClass,

    if (mainAxisAlignment != null)
      mainAxisAlignment!.cssClass,

    if (classes != null)
      classes!
  ];

  @css
  static List<StyleRule> get styles => [
    css('.column').styles(
      display: Display.flex,
      flexDirection: FlexDirection.column,
      gap: Gap.all(10.px)
    )
  ];
}