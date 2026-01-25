import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/num_field.dart';
import '../../components/controls/select.dart';
import '../../components/controls/int_vector_field.dart';
import '../../components/controls/num_vector_field.dart';
import '../../components/dialog/index.dart';
import '../../components/layout/index.dart';
import '../../simulator/wave_source.dart';
import '../../sources/point_source.dart';
import '../../sources/circle_pulse.dart';
import '../../util/types.dart';

/// Identifies the type of wave source
enum WaveType {
  /// A pulse at a single point
  pointPulse,

  /// A pulse at the perimeter of a circle
  circlePulse
}

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
    final type = MutableCell(WaveType.pointPulse);
    final source = MetaCell<WaveSource>();

    return Dialog(
        open: open,
        [
          form(method: FormMethod.dialog, [
            Column([
              h1([
                text('Add Wave')
              ]),
              Select(
                options: WaveType.values,
                selected: type,
                builder: (context, type) => switch (type) {
                  WaveType.pointPulse => text('Point Pulse'),
                  WaveType.circlePulse => text('Circular Pulse'),
                }
              ),
              _WaveSourceParameters(
                  source: source,
                  size: size,
                  type: type
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
                    onClick: () => onClose(source.value),
                    [text('Add')]
                )
              ])
            ])
          ])
        ]
    );
  }
}

/// Provides fields for entering the parameters of a wave source of a given [type].
class _WaveSourceParameters extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source of the given [type].
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  /// The type of wave source to create
  final ValueCell<WaveType> type;

  const _WaveSourceParameters({
    required this.source,
    required this.size,
    required this.type
  });

  @override
  Component build(BuildContext context) => switch (type()) {
    WaveType.pointPulse => _PointPulseForm(
        source: source,
        size: size
    ),

    WaveType.circlePulse => _CirclePulseForm(
        source: source,
        size: size
    ),
  };
}

/// Form for entering the parameters of a point pulse wave source
class _PointPulseForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _PointPulseForm({
    required this.source,
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

    source.inject(
      ValueCell.computed(() => PointPulse(
          position: position(),
          amplitude: amplitude()
      ))
    );

    return fragment([
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
      )
    ]);
  }
}

/// Form for entering the parameters of a circular pulse wave source.
class _CirclePulseForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _CirclePulseForm({
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final center = MutableCell(
        VectorI(
            x: 0,
            y: 0
        )
    );

    final radius = MutableCell(5.0);
    final amplitude = MutableCell(-1.0);

    source.inject(
        ValueCell.computed(() => CirclePulse(
            center: center(),
            radius: radius(),
            amplitude: amplitude()
        ))
    );

    return fragment([
      IntVectorField(
          title: 'Centre',
          value: center,
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
        title: 'Radius',
        value: radius
      ),
      NumField(
        title: 'Amplitude',
        value: amplitude,
      )
    ]);
  }
}