import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:web/web.dart';

import '../../simulator/wavesim2d.dart';
import '../../simulator/granule_renderer.dart';
import '../../simulator/wavesim_renderer.dart';
import '../../webgpu/index.dart';
import 'wavesim_state.dart';

/// Handles the initialization and updating of a [Wavesim2d].
class WavesimManager extends StatefulComponent {
  /// The GPU device to use for the simulation
  final GPUDevice device;

  /// Cell holding the canvas element to which, to render the simulation
  final ValueCell<HTMLCanvasElement?> canvas;

  /// Cell controlling the state of the simulation
  final ValueCell<WavesimState> state;

  /// Action cell for clearing the simulation.
  ///
  /// When this cell is triggered, the simulation is reset to equilibrium.
  final ValueCell<void>? clear;
  
  /// Child component to display underneath this component
  final Component child;

  // TODO: Extract simulation parameters

  const WavesimManager({
    super.key,
    required this.device,
    required this.canvas,
    required this.state,
    required this.child,
    this.clear
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

  /// Time (in milliseconds) of last update
  num _lastUpdateTime = 0;

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

        c: component.state.value.c
    );

    _simulator!.displace(
        x: 0, y: 0,
        dx: 1, dy: 1
    );

    await _simulator!.update();
  }

  /// Run the simulation
  void _run([DOMHighResTimeStamp? timestamp]) async {
    await _simulator?.update();

    final frameDelay = component.state.value.frameDelay.inMilliseconds;

    if (timestamp != null && frameDelay > 0) {
      final interval = timestamp - _lastUpdateTime;

      if (interval < frameDelay) {
        await Future.delayed(
            Duration(
                milliseconds: (frameDelay - interval).round()
            )
        );
      }

      _lastUpdateTime = timestamp;
    }

    if (_running) {
      window.requestAnimationFrame(_run.toJS);
    }
  }

  @override
  Component build(BuildContext context) => CellComponent.builder((context) {
    final ready = MutableCell(false);

    ValueCell.watch(() async {
      final canvas = component.canvas();

      if (_simulator == null && canvas != null) {
        await _initSimulator(canvas);
        ready.value = true;
      }
    });

    ValueCell.watch(() {
      if (ready()) {
        if (component.state.paused()) {
          _running = false;
        }
        else if (!_running) {
          _running = true;
          _run();
        }
      }
    });

    Watch((state) {
      component.clear?.observe();
      state.afterInit();

      _simulator?.clear();
    });

    Watch((state) {
      final c = component.state.c();
      state.afterInit();

      _simulator?.c = c;
    });

    return component.child;
  });
}