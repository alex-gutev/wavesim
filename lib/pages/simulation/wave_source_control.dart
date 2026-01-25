import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/int_vector_field.dart';
import '../../components/controls/num_vector_field.dart';
import '../../components/dialog/index.dart';
import '../../components/layout/index.dart';
import '../../simulator/wave_source.dart';
import '../../sources/point_source.dart';
import '../../util/types.dart';

/// A button for adding a wave source to the simulation
class WaveSourceControl extends CellComponent {
  /// Cell holding the list of sources
  final MutableCell<List<WaveSource>> sources;

  /// Cell holding the size of the simulation grid
  final ValueCell<int> size;

  const WaveSourceControl({
    required this.sources,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final open = MutableCell(false);

    return fragment([
      _WaveSourceDialog(
        open: open,
        size: size,
        onClose: sources.add,
      ),
      button(
          onClick: () => open.value = true,
          [
            text('Add Wave')
          ]
      )
    ]);
  }
}

/// Dialog for entering the parameters of a wave source
class _WaveSourceDialog extends CellComponent {
  /// Cell controlling whether the dialog is open
  final MutableCell<bool> open;

  /// Cell holding the size of the simulation grid
  final ValueCell<int> size;

  /// Callback called when the add button is clicked.
  ///
  /// The callback is passed the [source] which should be added to the
  /// simulation grid.
  final void Function(WaveSource source) onClose;

  const _WaveSourceDialog({
    required this.open,
    required this.onClose,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final position = MutableCell(
        VectorI(
            x: 0,
            y: 0
        )
    );

    final amplitude = MutableCell(
        VectorF(
            x: 0,
            y: 0
        )
    );

    return Dialog(
        open: open,
        [
          form(method: FormMethod.dialog, [
            Column([
              h1([
                text('Add Wave')
              ]),
              IntVectorField(
                  title: 'Position',
                  value: position,
                  min: VectorI(
                      x: -size(),
                      y: -size()
                  ),
                  max: VectorI(
                      x: size(),
                      y: size()
                  )
              ),
              NumVectorField(
                title: 'Amplitude',
                value: amplitude,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, [
                button(
                    type: ButtonType.button,
                    onClick: () => MutableCell.batch(() {
                      open.value = false;
                    }),

                    [text('Cancel')]
                ),
                button(
                    autofocus: true,
                    onClick: () => onClose(
                        PointPulse(
                            position: position.value,
                            amplitude: amplitude.value
                        )
                    ),

                    [text('Add')]
                )
              ])
            ])
          ])
        ]
    );
  }
}