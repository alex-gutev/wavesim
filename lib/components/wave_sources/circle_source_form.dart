import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../sources/circle_source.dart';
import '../../simulator/wave_source.dart';
import '../../util/types.dart';
import '../controls/index.dart';
import 'frequency_controls.dart';

/// Form for entering the parameters of a circular wave source.
class CircleSourceForm extends CellComponent {
  /// Cell holding circle source details.
  final MutableCell<CircleSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  /// Is an existing source being edited or a new source being added?
  final bool isEdit;

  const CircleSourceForm({
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
      IntegerField(
        title: 'Radius',
        value: source.radius,
        required: true,
        min: 1,
        max: (size() / 2).floor(),
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
      ),
    ]);
  }
}

/// Form for entering the parameters of a new circular wave source.
class NewCircleSourceForm extends CellComponent {
  /// Cell holding circle source details.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const NewCircleSourceForm({
    super.key,
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final circle = MutableCell(
        CircleSource(
            center: VectorI(x: 0, y:0),
            radius: 5,
            amplitude: -1
        )
    );

    source.inject(circle);

    return CircleSourceForm(
        source: circle,
        size: size
    );
  }
}
