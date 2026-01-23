import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';

import 'wavesim_state.dart';

/// Implementation of [WavesimCanvas] for server environments.
///
/// This is a stub implementation that simply returns an empty canvas.
class WavesimCanvasImpl extends StatelessComponent {
  /// Cell controlling the state of the simulator
  final MutableCell<WavesimState> state;

  /// Action cell for clearing the simulation
  final ValueCell<void>? clear;

  const WavesimCanvasImpl({
    super.key,
    required this.state,
    this.clear
  });

  @override
  Component build(BuildContext context) => Component.element(
      tag: 'canvas'
  );
}