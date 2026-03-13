import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../simulator/wave_source.dart';
import '../../sources/diverge_source.dart';
import '../../util/types.dart';
import '../controls/index.dart';
import 'frequency_controls.dart';

/// Form for entering the parameters of a divergence wave source.
class DivergeSourceForm extends CellComponent {
  /// Cell holding divergence source details.
  final MutableCell<DivergeSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  /// Is an existing source being edited or a new source being added?
  final bool isEdit;

  const DivergeSourceForm({
    super.key,
    required this.source,
    required this.size,
    this.isEdit = false
  });

  @override
  Component build(BuildContext context) {
    return fragment([
      IntVectorField(
          title: 'Centre',
          value: source.center,
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
      NumField(
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

/// Form for entering the parameters of a new divergence wave source.
class NewDivergeSourceForm extends CellComponent {
  /// Cell holding divergence source details.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const NewDivergeSourceForm({
    super.key,
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final divergence = MutableCell(
        DivergeSource(
            center: VectorI(x: 0, y:0),
            amplitude: 1
        )
    );

    source.inject(divergence);

    return DivergeSourceForm(
        source: divergence,
        size: size
    );
  }
}