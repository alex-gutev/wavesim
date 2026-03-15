import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:universal_web/web.dart';

import '../../webgpu/index.dart';
import '../util/ref_element.dart';
import 'wavesim_manager.dart';
import 'wavesim_state.dart';

/// Runs a wave simulation and renders the results to a canvas component
class WavesimCanvas extends CellComponent {
  /// Cell controlling the state of the simulator
  final MutableCell<WavesimState> state;

  /// Action cell for clearing the simulation
  ///
  /// When this cell is triggered, the simulation is reset to equilibrium.
  final ValueCell<void>? clear;

  /// The GPU device on which to run the simulation.
  final GPUDevice device;

  const WavesimCanvas({
    super.key,
    required this.state,
    required this.device,
    this.clear
  });

  @override
  Component build(BuildContext context) {
    final element = MutableCell<HTMLCanvasElement?>(null);

    final width = MutableCell(640);
    final height = MutableCell(640);

    return WavesimManager(
        device: device,
        canvas: element,
        state: state,
        clear: clear,

        child: RefElement(
            onElementReady: (e) {
              element.value = e as HTMLCanvasElement;
            },
            child: Component.element(
                tag: 'canvas',
                // TODO: Size canvas using CSS
                attributes: {
                  'width': width().toString(),
                  'height': height().toString()
                },

                events: {
                  'resize': (_) => MutableCell.batch(() {
                    final e = element.value;

                    if (e != null) {
                      width.value = e.clientWidth;
                      height.value = e.clientHeight;
                    }
                  })
                }
            )
        )
    );
  }
}