import 'package:jaspr/jaspr.dart';

import 'wavesim_canvas_server.dart' if (dart.library.js_interop)
  'wavesim_canvas_web.dart';

/// Runs a wave simulation and renders the results to a canvas component
class WavesimCanvas extends StatelessComponent {
  // TODO: Add simulation parameters

  const WavesimCanvas({
    super.key
  });

  @override
  Component build(BuildContext context) {
    return WavesimCanvasImpl();
  }
}