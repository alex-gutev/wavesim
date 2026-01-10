import 'package:jaspr/jaspr.dart';

/// Controls how the child components are placed along the cross axis in a flex layout
enum CrossAxisAlignment {
  /// Align the child components along the start of the cross axis
  start('flex-align-start'),

  /// Align the child components along the end of the cross axis
  end('flex-align-end'),

  /// Align the child components at the center of the cross axis
  center('flex-align-center'),

  /// Stretch the child components to fill the cross axis
  stretch('flex-align-stretch'),

  /// Align the child components along their baselines
  baseline('flex-align-baseline');

  /// The CSS class implementing the alignment
  final String cssClass;

  const CrossAxisAlignment(this.cssClass);
}

/// Controls how child components are placed along the main axis in a flex layout
enum MainAxisAlignment {
  /// Place the child components at the start of the main axis
  start('flex-justify-start'),

  /// Place the child components at the end of the main axis
  end('flex-justify-end'),

  /// Place the child components in the center of the main axis
  center('flex-justify-center'),

  /// Distribute the remaining space between the child components
  spaceBetween('flex-justify-space-between'),

  /// Distribute the remaining space around the child components
  spaceAround('flex-justify-space-around'),

  /// Distribute the remaining evenly between and around the child components
  spaceEvenly('flex-justify-space-evenly');

  /// The CSS class implementing the alignment
  final String cssClass;

  const MainAxisAlignment(this.cssClass);
}

@css
List<StyleRule> get styles => [
  css('.flex-align-start').styles(
    alignItems: AlignItems.start
  ),

  css('.flex-align-end').styles(
    alignItems: AlignItems.end
  ),

  css('.flex-align-center').styles(
    alignItems: AlignItems.center
  ),

  css('.flex-align-stretch').styles(
    alignItems: AlignItems.stretch
  ),

  css('.flex-align-baseline').styles(
    alignItems: AlignItems.baseline
  ),

  css('.flex-justify-start').styles(
    justifyContent: JustifyContent.start,
  ),

  css('.flex-justify-end').styles(
    justifyContent: JustifyContent.end,
  ),

  css('.flex-justify-center').styles(
    justifyContent: JustifyContent.center,
  ),

  css('.flex-justify-space-between').styles(
    justifyContent: JustifyContent.spaceBetween,
  ),

  css('.flex-justify-space-around').styles(
    justifyContent: JustifyContent.spaceAround,
  ),

  css('.flex-justify-space-evenly').styles(
    justifyContent: JustifyContent.spaceEvenly,
  )
];