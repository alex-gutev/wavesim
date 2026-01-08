import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:web/web.dart';

import '../../simulator/wavesim2d.dart';
import '../../simulator/granule_renderer.dart';
import '../../simulator/wavesim_renderer.dart';
import '../../webgpu/index.dart';

/// Handles the initialization and updating of a [Wavesim2d].
class WavesimManager extends StatefulComponent {
  /// The GPU device to use for the simulation
  final GPUDevice device;

  /// Cell holding the canvas element to which, to render the simulation
  final ValueCell<HTMLCanvasElement?> canvas;

  /// Cell controlling whether the simulation is paused or running
  ///
  /// When the cell is set to [true], the simulation is paused. When the
  /// cell is set to [false] the simulation is resumed.
  final ValueCell<bool> paused;

  /// Child component to display underneath this component
  final Component child;

  // TODO: Extract simulation parameters

  const WavesimManager({
    super.key,
    required this.device,
    required this.canvas,
    required this.paused,
    required this.child
  });

  @override
  State<WavesimManager> createState() =>
      _WavesimManagerState();
}

class _WavesimManagerState extends State<WavesimManager> {
  /// The simulator
  Wavesim2d? _simulator;

  /// Is the simulation running or not
  var _running = false;

  // TODO: Implement dispose

  /// Create the simulator
  Future<void> _initSimulator(HTMLCanvasElement canvas) async {
    final device = component.device;

    final shader = await loadShader(
        device: device,
        url: Uri.parse('/shaders/compute.wgsl')
    );

    // TODO: Handle errors during shader loading

    _simulator = Wavesim2d(
        device: component.device,
        shader: shader,

        renderer: GranuleRenderer(
          device: device,
          context: canvas.getContext('webgpu') as GPUCanvasContext,

          shader: await loadShader(
            device: device,
            url: Uri.parse('/shaders/render_wave.wgsl'),
          ),
        ),

        size: Size(
            width: 10,
            height: 10
        ),

        c: 1
    );

    _simulator!.displace(
        x: 0, y: 0,
        dx: 1, dy: 1
    );

    await _simulator!.update();
  }

  /// Run the simulation
  void _run() async {
    await _simulator?.update();

    if (_running) {
      window.requestAnimationFrame(_run.toJS);
    }
  }

  @override
  Component build(BuildContext context) => CellComponent.builder((context) {
    final ready = MutableCell(false);

    Watch((state) async {
      final canvas = component.canvas();

      if (canvas != null) {
        state.stop();
        await _initSimulator(canvas);

        ready.value = true;
      }
    });

    ValueCell.watch(() {
      if (ready()) {
        if (component.paused()) {
          _running = false;
        }
        else if (!_running) {
          _running = true;
          _run();
        }
      }
    });

    return component.child;
  });
}