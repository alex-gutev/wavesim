import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../components/controls/index.dart';
import '../../components/dialog/index.dart';
import '../../components/layout/index.dart';
import '../../components/wave_sources/index.dart';
import '../../simulator/wave_source.dart';
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