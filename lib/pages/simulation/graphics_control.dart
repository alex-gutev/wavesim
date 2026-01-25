import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/wavesim/index.dart';

/// Controls for selecting the type of graphics rendering to use for the simulation.
class GraphicsControls extends CellComponent {
  /// Cell holding the selected graphics type
  final MutableCell<WavesimGraphics> graphics;

  const GraphicsControls({required this.graphics});

  @override
  Component build(BuildContext context) => fragment([
    label([text('Graphics')]),
    label([
      input(
          type: InputType.radio,
          name: 'wavesim-graphics',
          value: WavesimGraphics.blocks.name,

          onChange: (e) {
            graphics.value = WavesimGraphics.blocks;
          },

          checked: graphics.value == WavesimGraphics.blocks
      ),
      text('Blocks')
    ]),
    label([
      input(
          type: InputType.radio,
          name: 'wavesim-graphics',
          value: WavesimGraphics.heatmap.name,

          onChange: (e) {
            graphics.value = WavesimGraphics.heatmap;
          },

          checked: graphics.value == WavesimGraphics.heatmap
      ),
      text('Heatmap')
    ])
  ]);
}
