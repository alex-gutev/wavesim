import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/index.dart';
import '../../components/wavesim/index.dart';

/// Controls for selecting the type of graphics rendering to use for the simulation.
class GraphicsControls extends CellComponent {
  /// Cell holding the selected graphics type
  final MutableCell<WavesimGraphics> graphics;

  const GraphicsControls({required this.graphics});

  @override
  Component build(BuildContext context) => fragment([
    Select(
        title: 'Graphics',
        options: WavesimGraphics.values,
        selected: graphics,
        builder: (_, type) => switch (type) {
          WavesimGraphics.vector => text('Vectors'),
          WavesimGraphics.blocks => text('Blocks'),
          WavesimGraphics.heatmap => text('Density'),
          WavesimGraphics.colorX => text('X Amplitude'),
          WavesimGraphics.colorY => text('Y Amplitude'),
          WavesimGraphics.grid => text('Grid'),
        }
    )
  ]);
}
