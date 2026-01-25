import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/layout/index.dart';
import '../../components/wavesim/index.dart';
import 'wavesim_controls.dart';

/// The page containing the wave simulation
class Simulation extends CellComponent {
  const Simulation({super.key});

  @override
  Component build(BuildContext context) {
    final simState = MutableCell(
      WavesimState(
        paused: true,
        size: 150,
        graphics: WavesimGraphics.heatmap
      )
    );

    final clear = ActionCell();

    return section([
      Row(crossAxisAlignment: CrossAxisAlignment.stretch, [
        WavesimCanvas(
          state: simState,
          clear: clear
        ),
        WavesimControls(
            state: simState,
            clear: clear
        )
      ])
    ]);
  }
}