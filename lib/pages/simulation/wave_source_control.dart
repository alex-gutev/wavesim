import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/icon.dart';
import '../../constants/button_styles.dart';
import '../../constants/icons.dart';
import '../../components/controls/index.dart';
import '../../components/dialog/index.dart';
import '../../components/layout/index.dart';
import '../../components/wave_sources/index.dart';
import '../../simulator/wave_source.dart';
import '../../sources/index.dart';
import '../../util/extensions.dart';

/// Identifies the type of wave source
enum WaveType {
  point,
  line,
  circle,
  curl,
  diverge,
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
            sources: sources,
            size: size
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
class _SourceItem extends CellComponent {
  /// Cell holding the details of the wave source
  final MutableCell<WaveSource> source;

  /// The size of the simulation grid
  final ValueCell<int> size;

  const _SourceItem({
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final open = MutableCell(false);

    return div([
      _EditWaveSourceDialog(
          open: open,
          size: size,
          source: source
      ),
      CellComponent.builder((_) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          [
            button(
                classes: ButtonStyles.icon,
                type: ButtonType.button,
                onClick: () => open.value = true,
                [
                  Icon(
                    src: Icons.edit,
                  )
                ]
            ),
            text(source().toString())
          ]
      ))
    ]);
  }
}

/// Displays the list of wave sources
class _WaveSourceList extends CellComponent {
  /// List of wave sources
  final MutableCell<List<WaveSource>> sources;

  /// Size of the simulation grid
  final ValueCell<int> size;

  const _WaveSourceList({
    required this.sources,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    return Column(
        classes: 'wave-source-list',
        [
          for (var i = 0; i < sources.length(); i++)
            _SourceItem(
              source: sources[i.cell],
              size: size
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
    WaveType.point => NewPointSourceForm(
        source: source,
        size: size
    ),

    WaveType.line => NewLineSourceForm(
        source: source,
        size: size
    ),

    WaveType.circle => NewCircleSourceForm(
        source: source,
        size: size
    ),

    WaveType.diverge => NewDivergeSourceForm(
        source: source,
        size: size
    ),

    WaveType.curl => NewCurlSourceForm(
      source: source,
      size: size
    ),
  };
}

/// Dialog for editing the details of a wave source.
class _EditWaveSourceDialog extends CellComponent {
  /// Cell controlling whether the dialog is open
  final MutableCell<bool> open;

  /// Cell holding the size of the simulation grid
  final ValueCell<int> size;

  /// Cell holding the wave source details
  final MutableCell<WaveSource> source;

  const _EditWaveSourceDialog({
    super.key,
    required this.open,
    required this.size,
    required this.source
  });

  @override
  Component build(BuildContext context) {
    final close = ActionCell();

    return Dialog(
      open: open,
      [
        Form(
            submit: close,
            method: FormMethod.dialog,
            [
              Column([
                _EditSourceForm(
                    source: source,
                    size: size
                ),
                button([
                  text('Close')
                ])
              ])
            ]
        )
      ]
    );
  }
}

/// Form for editing the details of a wave source
class _EditSourceForm extends CellComponent {
  /// Cell holding the details of the wave source
  final MutableCell<WaveSource> source;

  /// The size of the simulation grid
  final ValueCell<int> size;

  const _EditSourceForm({
    required this.source,
    required this.size
  });

  @override
  Component build(BuildContext context) => switch (source()) {
    PointSource _ => PointSourceForm(
        source: source.transform(),
        size: size,
        isEdit: true
    ),

    LineSource _ => LineSourceForm(
        source: source.transform(),
        size: size,
        isEdit: true

    ),

    CircleSource _ => CircleSourceForm(
        source: source.transform(),
        size: size,
        isEdit: true

    ),

    DivergeSource _ => DivergeSourceForm(
        source: source.transform(),
        size: size,
        isEdit: true

    ),

    CurlSource _ => CurlSourceForm(
        source: source.transform(),
        size: size,
        isEdit: true
    ),

    _ => throw UnimplementedError()
  };
}