import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:web/web.dart';

import '../gpu/web_gpu_check.dart';
import '../util/ref_element.dart';
import 'wavesim_state.dart';
import 'wavesim_manager.dart';

/// Implementation of [WavesimCanvas] for browser environments
class WavesimCanvasImpl extends CellComponent {
  /// Cell controlling the state of the simulator
  final ValueCell<WavesimState> state;

  /// Action cell for clearing the simulation
  final ValueCell<void>? clear;

  const WavesimCanvasImpl({
    super.key,
    required this.state,
    this.clear
  });

  @override
  Component build(BuildContext context) {
    final element = MutableCell<HTMLCanvasElement?>(null);

    return WebGPUCheck(
        builder: (context, device) {
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
                        'width': '640',
                        'height': '640'
                      }
                  )
              )
          );
        }
    );
  }
}