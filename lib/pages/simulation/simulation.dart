import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../constants/theme.dart';
import 'wave_source_control.dart';
import '../../components/wavesim/index.dart';
import 'wavesim_controls.dart';

/// The page containing the wave simulation
class Simulation extends CellComponent {
  const Simulation({super.key});

  @override
  Component build(BuildContext context) {
    final simState = MutableCell(
      WavesimState(
        paused: true,
        size: 50,
        graphics: WavesimGraphics.vector
      )
    );

    final clear = ActionCell();

    return div(classes: 'simulation-grid', [
      div(classes: 'simulation-controls', [
        WavesimControls(
            state: simState,
            clear: clear
        )
      ]),
      div(classes: 'wave-sources', [
        WaveSourceControl(
            sources: simState.sources,
            size: simState.size
        )
      ]),
      main_([
        WavesimCanvas(
            state: simState,
            clear: clear
        ),
      ])
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.simulation-grid', [
      css('&').styles(
        display: Display.grid,
        width: 100.percent,
        height: 100.vh,

        gridTemplate: GridTemplate(
            columns: GridTracks([
              GridTrack(TrackSize.auto),
              GridTrack(TrackSize.fr(1))
            ]),

            rows: GridTracks([
              GridTrack(TrackSize.auto),
              GridTrack(TrackSize.fr(1)),
              GridTrack(TrackSize.fr(1)),
              GridTrack(TrackSize.auto)
            ]),

            areas: GridAreas([
              'hd hd',
              'sd main',
              'wv main',
              'ft ft'
            ])
        )
      ),


      css('> .simulation-controls').styles(
        gridPlacement: GridPlacement.area('sd'),
        padding: Padding.all(0.5.rem),

        border: Border.only(
            right: BorderSide.solid(
                width: 2.px,
                color: Theme.border
            )
        )
      ),

      css('> .wave-sources').styles(
        gridPlacement: GridPlacement.area('wv'),
        padding: Padding.all(0.5.rem),
        border: Border.only(
          top: BorderSide.solid(
            width: 2.px,
            color: Theme.border
          ),
          right: BorderSide.solid(
              width: 2.px,
              color: Theme.border
          )
        )
      ),

      css('> main').styles(
          gridPlacement: GridPlacement.area('main'),

          display: Display.flex,
          flexDirection: FlexDirection.column,
          overflow: Overflow.scroll,

          alignItems: AlignItems.center,
          justifyContent: JustifyContent.center
      ),

      css('canvas').styles(
        width: Unit.auto,
        height: 100.percent,
        aspectRatio: AspectRatio(1, 1)
      ),

      css('> header').styles(
          gridPlacement: GridPlacement.area('hd')
      ),

      css('> footer').styles(
          gridPlacement: GridPlacement.area('ft')
      )
    ])
  ];
}