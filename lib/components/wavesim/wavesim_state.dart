import 'package:live_cells_core/live_cells_core.dart';

import '../../simulator/wave_source.dart';
import '../../util/equality.dart';

part 'wavesim_state.g.dart';

/// Represents the type of graphics rendering for a simulation
enum WavesimGraphics {
  /// Render the state as grid of arrows
  vector,

  /// Render the state as discrete blocks
  blocks,

  /// Render the state as a heatmap
  heatmap
}

/// Represents the state of a wave simulator.
@CellExtension(mutable: true)
class WavesimState {
  /// Is the simulation paused (true) or running (false).
  final bool paused;

  /// The delay between successive frames.
  ///
  /// If this is not null, the simulation ensures that the interval between
  /// successive frames is at least this duration.
  final Duration frameDelay;

  /// The of the simulation grid
  final int size;

  /// Energy transfer coefficient in the range (0, 1].
  final double c;

  /// Graphics renderer to use
  final WavesimGraphics graphics;

  /// List of wave sources
  @listField
  final List<WaveSource> sources;

  /// Is the grid boundary closed or open?
  final bool closed;

  const WavesimState({
    required this.paused,
    required this.size,
    this.frameDelay = Duration.zero,
    this.c = 1,
    this.graphics = WavesimGraphics.blocks,
    this.sources = const [],
    this.closed = false
  });

  @override
  bool operator ==(Object other) =>
      _$WavesimStateEquals(this, other);

  @override
  int get hashCode => _$WavesimStateHashCode(this);
}