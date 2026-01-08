import 'package:jaspr/jaspr.dart';

/// Implementation of [WavesimCanvas] for server environments.
///
/// This is a stub implementation that simply returns an empty canvas.
class WavesimCanvasImpl extends StatelessComponent {
  @override
  Component build(BuildContext context) => Component.element(
      tag: 'canvas'
  );
}