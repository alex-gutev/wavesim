import 'package:jaspr/jaspr.dart';

// As your css styles are defined using just Dart, you can simply
// use global variables or methods for common things like colors.
const primaryColor = Color('#01589B');

/// Theme colour constants
class Theme {
  /// The primary color of the theme
  static const primary = Color.variable(varPrimary);
  static const varPrimary = '--primary-color';

  /// Error text colour
  static const error = Color.variable(varError);
  static const varError = '--error-color';

  /// Error container colour
  static final errorContainer = Color.variable('--error-container-color');

  /// Container background color
  static const container = Color.variable(varContainer);
  static const varContainer = '--primary-container-color';

  /// Color to use for borders
  static const border = Color.variable(varBorder);
  static const varBorder = '--border-color';

  /// Application background color
  static const background = Color.variable('--background-color');

  /// Button background color
  static const buttonBackground = Color.variable(varButtonBackground);
  static const varButtonBackground = '--button-background-color';

  /// Button text color
  static const buttonForeground = Color.variable(varButtonForeground);
  static const varButtonForeground = '--button-foreground-color';

  /// Disabled component color
  static const disabled = Color.variable(varDisabled);
  static const varDisabled = '--disabled-color';

  /// Focused field color
  static const focus = Color.variable(varFocus);
  static const varFocus = '--focus-color';

  /// Color representing something that needs attention
  static const attention = Color.variable(varAttention);
  static const varAttention = '--attention-color';

  /// Color representing an alert
  static const alert = Color.variable(varAlert);
  static const varAlert = '--alert-color';

  /// Completed step color
  static const done = Color.variable(varDone);
  static const varDone = '--done-color';

  static const ok = Color.variable(varOk);
  static const varOk = '--ok-color';

  @css
  static List<StyleRule> get styles => [
    css(':root').styles(
        raw: {
          varPrimary: '#183f6f',
          varError: '#610E09',
          '--error-container-color': 'hsl(from var(--error-color) h s 95%)',
          varContainer: '#f3f3fa',
          varBorder: '#d1d9d0',
          '--background-color': '#f9f9ff',
          varButtonBackground: '#4d6c99',
          varButtonForeground: '#ffffff',
          varDisabled: '#c1c1c1',
          varFocus: '#183f6f',
          varAttention: '#f44336',
          varAlert: '#ff0000',
          varDone: '#00866f',
          varOk: '#4CAF50'
        }
    ),
  ];
}