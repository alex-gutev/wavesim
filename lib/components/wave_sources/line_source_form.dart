import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../simulator/wave_source.dart';
import '../../sources/line_source.dart';
import '../../util/types.dart';
import '../controls/index.dart';
import 'frequency_controls.dart';

/// Form for entering the parameters of a line wave source.
class LineSourceForm extends CellComponent {
  /// Cell holding details of line source.
  final MutableCell<LineSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  /// Is an existing source being edited or a new source being added?
  final bool isEdit;

  const LineSourceForm({
    super.key,
    required this.source,
    required this.size,
    this.isEdit = false
  });

  @override
  Component build(BuildContext context) {
    return fragment([
      IntVectorField(
          title: 'Start',
          value: source.start,
          required: true,

          min: VectorI(
              x: -size(),
              y: -size()
          ),

          max: VectorI(
              x: size(),
              y: size()
          )
      ),
      IntVectorField(
          title: 'End',
          value: source.end,
          required: true,

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
          value: source.amplitude,
          required: true
      ),
      FrequencyControls(
          frequency: source.frequency,
          phase: source.phase,
          maxSteps: source.maxSteps,
          isEdit: isEdit
      )
    ]);
  }
}

/// Form for entering the parameters of a new line wave source.
class NewLineSourceForm extends CellComponent {
  /// Cell holding details of line source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const NewLineSourceForm({
    super.key,
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final line = MutableCell(
        LineSource(
          start: VectorI(x: 0, y: 0),
          end: VectorI(x: 0, y: 0),
          amplitude: VectorF(x: 0, y: 0),
        )
    );

    source.inject(line);

    return LineSourceForm(
        source: line,
        size: size
    );
  }
}
