import 'package:live_cells_core/live_cells_core.dart';

part 'wavesim_state.g.dart';

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

  const WavesimState({
    required this.paused,
    this.frameDelay = Duration.zero
  });

  @override
  bool operator ==(Object other) =>
      _$WavesimStateEquals(this, other);

  @override
  int get hashCode => _$WavesimStateHashCode(this);
}