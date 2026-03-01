import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import '../../simulator/wave_source.dart';
import '../../simulator/wavesim2d.dart';
import '../../simulator/granule_renderer.dart';
import '../../simulator/heatmap_renderer.dart';
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
  final MutableCell<WavesimState> state;

  /// Action cell for clearing the simulation.
  ///
  /// When this cell is triggered, the simulation is reset to equilibrium.
  final ValueCell<void>? clear;
  
  /// Child component to display underneath this component
  final Component child;

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
  static const debounceDelay = Duration(milliseconds: 300);

  /// The simulator
  Wavesim2d? _simulator;

  /// Is the simulation running or not
  var _running = false;

  /// Time (in milliseconds) of last update
  num _lastUpdateTime = 0;

  @override
  void dispose() {
    _simulator?.dispose();
    _simulator = null;

    super.dispose();
  }

  /// Create the simulator
  Future<void> _initSimulator(HTMLCanvasElement canvas) async {
    await _makeSimulator(canvas);

    // TODO: Rethink whether it would be better to just render the blank state
    await _simulator!.update();
  }

  Future<void> _makeSimulator(HTMLCanvasElement canvas) async {
    _simulator = Wavesim2d(
        device: component.device,

        renderer: _makeRenderer(
            type: component.state.value.graphics,
            canvas: canvas
        ),

        size: component.state.value.size,
        c: component.state.value.c
    );

    await _simulator!.render();
  }

  /// Run the simulation
  void _run([DOMHighResTimeStamp? timestamp]) async {
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

    _updateSources();

    await _simulator?.update();

    if (_running) {
      window.requestAnimationFrame(_run.toJS);
    }
  }

  /// Create a renderer for a given graphics [type].
  WavesimRenderer _makeRenderer({
    required WavesimGraphics type,
    required HTMLCanvasElement canvas
  }) => switch (type) {
    WavesimGraphics.blocks => GranuleRenderer(
      device: component.device,
      context: canvas.getContext('webgpu') as GPUCanvasContext,
    ),

    WavesimGraphics.heatmap => HeatmapRenderer(
      device: component.device,
      context: canvas.getContext('webgpu') as GPUCanvasContext,
    ),
  };

  /// Update the wave sources
  void _updateSources() {
    if (_simulator != null) {
      var changed = false;
      final sources = <WaveSource>[];

      for (final source in component.state.value.sources) {
        if (source.update(_simulator!)) {
          sources.add(source);
        }
        else {
          changed = true;
        }
      }

      if (changed) {
        component.state.sources.value = sources;
      }
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
      // TODO: Ensure this doesn't cause an initial delay
      final c = component.state.c
        .delayed(debounceDelay)
        .waitLast
        .whenReady();

      state.afterInit();

      _simulator?.c = c;
    });

    _watchGraphicsType();
    _watchSize();
    _watchBoundary();

    return component.child;
  });

  /// Add a watch function that updates the graphics type of the simulation.
  void _watchGraphicsType() {
    Watch((state) {
      final type = component.state.graphics();
      state.afterInit();

      _updateGraphicsType(
          canvas: component.canvas()!,
          type: type
      );
    });
  }

  Future<void> _updateGraphicsType({
    required HTMLCanvasElement canvas,
    required WavesimGraphics type
  }) async {
    _simulator?.renderer = _makeRenderer(
        type: type,
        canvas: canvas
    );
  }

  /// Recreate the simulator when the size of the simulation is changed
  void _watchSize() {
    Watch((state) {
      component.state.size.observe();
      state.afterInit();

      final canvas = component.canvas();

      if (canvas != null) {
        _simulator?.dispose();
        _makeSimulator(canvas);
      }
    });
  }

  void _watchBoundary() {
    Watch((state) {
      final closed = component.state.closed();
      state.afterInit();

      _simulator?.closed = closed;
    });
  }
}