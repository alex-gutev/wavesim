import 'package:jaspr/jaspr.dart';

import 'layout/index.dart';

/// Displays an image with a label.
///
/// The image is styled to match the height of the textual label
class Icon extends StatelessComponent {
  /// URL to the image source
  final String src;

  /// Textual label displayed next to the image
  final String? label;

  /// Horizontal alignment of the icon and label.
  final MainAxisAlignment? mainAxisAlignment;

  /// Additional classes to add to the component
  final String? classes;

  const Icon({
    super.key,
    required this.src,
    this.classes,
    this.label,
    this.mainAxisAlignment,
  });

  @override
  Component build(BuildContext context) => Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: mainAxisAlignment,
      classes: classes,
      [
        svg(classes: 'icon', viewBox: '0 0 50 50', [
          Component.element(
            tag: 'use',
            attributes: {
              'href': '$src#root',
              'width': '50',
              'height': '50'
            }
          )
        ]),
        if (label != null)
          span([text(label!)])
      ]
  );

  @css
  static List<StyleRule> get styles => [
    css('svg.icon').styles(
      height: 1.em,
    ),

    css('.large-icon').styles(
      fontSize: 2.em
    )
  ];
}