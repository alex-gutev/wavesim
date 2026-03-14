import 'package:jaspr/jaspr.dart';

import 'theme.dart';

/// Button style class constants
class ButtonStyles {
  /// Destructive button class.
  ///
  /// This should be used for buttons which represent a "dangerous" or
  /// "destructive" operation.
  static const destructive = 'destructive';

  /// Text button class.
  static const text = 'text';

  /// Icon button class
  static const icon = 'icon-button';

  /// Button with an outline online
  static const outlined = 'outlined-button';

  // Prevent instantiation
  ButtonStyles._internal();

  @css
  static List<StyleRule> get styles => [
    css('button.$destructive').styles(
        raw: {
          Theme.varButtonBackground: 'var(${Theme.varError})'
        }
    ),

    css('button.$text', [
      css('&').styles(
          raw: {
            Theme.varButtonBackground: 'transparent',
            Theme.varButtonForeground: 'var(${Theme.varPrimary})'
          }
      ),

      css('&:hover').styles(
          raw: {
            Theme.varButtonBackground: 'var(${Theme.varContainer})'
          }
      ),
    ]),

    css('button.$icon', [
      css('&').styles(
        display: Display.inlineFlex,
        justifyContent: JustifyContent.center,
        alignContent: AlignContent.center,
        radius: BorderRadius.circular(50.percent),
        padding: Padding.all(0.5.em),
        boxSizing: BoxSizing.borderBox,
      )
    ]),

    css('button.$outlined', [
      css('&').styles(
        border: Border(
          color: Theme.border,
          width: 2.px
        ),
        raw: {
          Theme.varButtonForeground: 'var(${Theme.varPrimary})',
          Theme.varButtonBackground: 'white'
        }
      ),

      css('&:hover').styles(
        border: Border(
          color: Theme.primary,
          width: 2.px
        )
      )
    ])
  ];
}