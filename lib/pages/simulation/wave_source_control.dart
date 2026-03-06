import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/index.dart';
import '../../components/dialog/index.dart';
import '../../components/layout/index.dart';
import '../../simulator/wave_source.dart';
import '../../sources/point_source.dart';
import '../../sources/curl_source.dart';
import '../../sources/circle_source.dart';
import '../../sources/diverge_source.dart';
import '../../sources/line_source.dart';
import '../../sources/circle_standing_wave.dart';
import '../../util/extensions.dart';
import '../../util/types.dart';

/// Identifies the type of wave source
enum WaveType {
  point,
  line,
  circle,
  curl,
  diverge,
  circleStandingWave
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

    return Column(classes: 'wave-source-control', [
      _WaveSourceDialog(
        open: open,
        size: size,
        onClose: sources.add,
      ),
      Expanded(
          _WaveSourceList(
            sources: sources
          )
      ),
      button(
          onClick: () => open.value = true,
          [
            text('Add Wave')
          ]
      )
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.wave-source-control').styles(
      height: 100.percent
    ),
    css('.wave-source-list').styles(
      overflow: Overflow.only(
        y: Overflow.scroll
      )
    )
  ];
}

/// An item in the wave source list
class _SourceItem extends StatelessComponent {
  final WaveSource source;

  const _SourceItem({
    required this.source
  });

  @override
  Component build(BuildContext context) => label([
    text(source.toString())
  ]);
}

/// Displays the list of wave sources
class _WaveSourceList extends CellComponent {
  /// List of wave sources
  final ValueCell<List<WaveSource>> sources;

  const _WaveSourceList({
    required this.sources
  });

  @override
  Component build(BuildContext context) {
    return Column(
        classes: 'wave-source-list',
        [
          for (final source in sources())
            _SourceItem(
                source: source
            )
        ]
    );
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
    final type = MutableCell(WaveType.point);
    final source = MetaCell<WaveSource>();
    final add = ActionCell();

    add.watch(() {
      onClose(source.peek());
    });

    return Dialog(
        open: open,
        [
          Form(
            method: FormMethod.dialog,
            submit: add,
            [
              Column([
                h1([
                  text('Add Wave')
                ]),
                Select(
                    options: WaveType.values,
                    selected: type,
                    builder: (context, type) => switch (type) {
                      WaveType.point => text('Point'),
                      WaveType.line => text('Line'),
                      WaveType.circle => text('Circle'),
                      WaveType.diverge => text('Divergence'),
                      WaveType.curl => text('Curl'),
                      WaveType.circleStandingWave => text('Circular Standing Wave'),
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
                      onClick: () => open.value = false,
                      [text('Cancel')]
                  ),
                  button(
                      autofocus: true,
                      [text('Add')]
                  )
                ])
              ])
            ]
          )
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
    WaveType.point => _PointSourceForm(
        source: source,
        size: size
    ),

    WaveType.line => _LineSourceForm(
        source: source,
        size: size
    ),

    WaveType.circle => _CircleSourceForm(
        source: source,
        size: size
    ),

    WaveType.diverge => _DivergeSourceForm(
        source: source,
        size: size
    ),

    WaveType.curl => _CurlSourceForm(
      source: source,
      size: size
    ),

    WaveType.circleStandingWave => _CircleStandingWaveForm(
        source: source,
        size: size
    ),
  };
}

/// Form for entering the parameters of a point wave source
class _PointSourceForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _PointSourceForm({
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final pointSource = MutableCell(
      PointSource(
        position: VectorI(x: 0, y: 0),
        amplitude: VectorF(x: 0, y: 0),
      )
    );

    final isPulse = MutableCell.computed(() => pointSource.maxSteps() == 1, (pulse) {
      pointSource.maxSteps.value = pulse ? 1 : null;
    });

    source.inject(pointSource);

    return fragment([
      IntVectorField(
          title: 'Position',
          value: pointSource.position,
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
        value: pointSource.amplitude,
        required: true
      ),
      Checkbox(
        checked: isPulse,
        trailing: text('Pulse')
      ),
      NumField(
          title: 'Frequency',
          value: pointSource.frequency,
          min: 0,
          enabled: !isPulse()
      )
    ]);
  }
}

/// Form for entering the parameters of a circular wave source.
class _CircleSourceForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _CircleSourceForm({
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final circleSource = MutableCell(
      CircleSource(
        center: VectorI(x: 0, y:0),
        radius: 5,
        amplitude: -1
      )
    );


    final isPulse = MutableCell.computed(() => circleSource.maxSteps() == 1, (pulse) {
      circleSource.maxSteps.value = pulse ? 1 : null;
    });

    source.inject(circleSource);

    return fragment([
      IntVectorField(
          title: 'Centre',
          value: circleSource.center,
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
        value: circleSource.radius,
        required: true,
        min: 1,
        max: (size() / 2).floor(),
      ),
      NumField(
        title: 'Amplitude',
        value: circleSource.amplitude,
        required: true
      ),
      Checkbox(
          checked: isPulse,
          trailing: text('Pulse')
      ),
      NumField(
          title: 'Frequency',
          value: circleSource.frequency,
          min: 0,
          enabled: !isPulse()
      )
    ]);
  }
}

/// Form for entering the parameters of a divergence wave source.
class _DivergeSourceForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _DivergeSourceForm({
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


    final isPulse = MutableCell.computed(() => divergence.maxSteps() == 1, (pulse) {
      divergence.maxSteps.value = pulse ? 1 : null;
    });

    source.inject(divergence);

    return fragment([
      IntVectorField(
          title: 'Centre',
          value: divergence.center,
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
          value: divergence.amplitude,
          required: true
      ),
      Checkbox(
          checked: isPulse,
          trailing: text('Pulse')
      ),
      NumField(
          title: 'Frequency',
          value: divergence.frequency,
          min: 0,
          enabled: !isPulse()
      )
    ]);
  }
}

/// Form for entering the parameters of a curl wave source.
class _CurlSourceForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _CurlSourceForm({
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final curl = MutableCell(
        CurlSource(
            center: VectorI(x: 0, y:0),
            amplitude: 1
        )
    );


    final isPulse = MutableCell.computed(() => curl.maxSteps() == 1, (pulse) {
      curl.maxSteps.value = pulse ? 1 : null;
    });

    source.inject(curl);

    return fragment([
      IntVectorField(
          title: 'Centre',
          value: curl.center,
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
          value: curl.amplitude,
          required: true
      ),
      Checkbox(
          checked: isPulse,
          trailing: text('Pulse')
      ),
      NumField(
          title: 'Frequency',
          value: curl.frequency,
          min: 0,
          enabled: !isPulse()
      )
    ]);
  }
}

/// Form for entering the parameters of a line wave source.
class _LineSourceForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _LineSourceForm({
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

    final isPulse = MutableCell.computed(() => line.maxSteps() == 1, (pulse) {
      line.maxSteps.value = pulse ? 1 : null;
    });

    source.inject(line);

    return fragment([
      IntVectorField(
          title: 'Start',
          value: line.start,
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
          value: line.end,
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
          value: line.amplitude,
          required: true
      ),
      Checkbox(
          checked: isPulse,
          trailing: text('Pulse')
      ),
      NumField(
          title: 'Frequency',
          value: line.frequency,
          min: 0,
          enabled: !isPulse()
      )
    ]);
  }
}

/// Form for entering the parameters of a circular pulse wave source.
class _CircleStandingWaveForm extends CellComponent {
  /// Meta cell injected with a cell that constructs the wave source.
  final MetaCell<WaveSource> source;

  /// The size of the grid
  final ValueCell<int> size;

  const _CircleStandingWaveForm({
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

    final radius = MutableCell(5);
    final amplitude = MutableCell(-1.0);

    source.inject(
        ValueCell.computed(() => CircleStandingWave(
            center: center(),
            radius: radius(),
            amplitude: amplitude()
        ))
    );

    return fragment([
      IntVectorField(
          title: 'Centre',
          value: center,
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
          value: radius,
          required: true,
          min: 1,
          max: (size() / 2).floor()
      ),
      NumField(
        title: 'Amplitude',
        value: amplitude,
        required: true
      )
    ]);
  }
}