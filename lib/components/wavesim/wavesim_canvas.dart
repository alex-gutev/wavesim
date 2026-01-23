import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';

import 'wavesim_canvas_server.dart' if (dart.library.js_interop)
  'wavesim_canvas_web.dart';
import 'wavesim_state.dart';

/// Runs a wave simulation and renders the results to a canvas component
class WavesimCanvas extends StatelessComponent {
  /// Cell controlling the state of the simulator
  final MutableCell<WavesimState> state;

  /// Action cell for clearing the simulation
  ///
  /// When this cell is triggered, the simulation is reset to equilibrium.
  final ValueCell<void>? clear;

  const WavesimCanvas({
    super.key,
    required this.state,
    this.clear
  });

  @override
  Component build(BuildContext context) {
    return WavesimCanvasImpl(
      state: state,
      clear: clear
    );
  }
}