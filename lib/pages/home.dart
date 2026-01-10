import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../components/layout/index.dart';
import '../components/wavesim/index.dart';

class Home extends CellComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final simState = MutableCell(
      WavesimState(
        paused: true
      )
    );

    return section([
      Row(crossAxisAlignment: CrossAxisAlignment.stretch, [
        WavesimCanvas(
            state: simState
        ),
        WavesimControls(
            state: simState
        )
      ])
    ]);
  }
}

class WavesimControls extends CellComponent {
  final MutableCell<WavesimState> state;

  const WavesimControls({
    required this.state
  });

  @override
  Component build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        [
          button(
              onClick: () => state.paused.value = !state.paused.value,
              [
                text(
                    state.paused() ? 'Run' : 'Pause'
                )
              ]
          ),
        ]
    );
  }
}