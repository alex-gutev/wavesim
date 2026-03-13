import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../simulator/wave_source.dart';
import '../../sources/point_source.dart';
import '../../util/types.dart';
import '../controls/index.dart';
import 'frequency_controls.dart';

/// Form for entering the parameters of a point wave source
class PointSourceForm extends CellComponent {
  /// Cell holding point source details
  final MutableCell<PointSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  /// Is an existing source being edited or a new source being added?
  final bool isEdit;

  const PointSourceForm({
    super.key,
    required this.source,
    required this.size,
    this.isEdit = false
  });

  @override
  Component build(BuildContext context) {
    return fragment([
      IntVectorField(
          title: 'Position',
          value: source.position,
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
      ),
    ]);
  }
}

/// Form for entering the parameters of a new point wave source
class NewPointSourceForm extends CellComponent {
  /// Cell holding point source details
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const NewPointSourceForm({
    super.key,
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final point = MutableCell(
        PointSource(
          position: VectorI(x: 0, y: 0),
          amplitude: VectorF(x: 0, y: 0),
        )
    );

    source.inject(point);

    return PointSourceForm(
        source: point,
        size: size
    );
  }
}