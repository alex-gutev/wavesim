/// Wave simulation engine interface
abstract interface class WavesimEngine2D {
  /// Displace a granule at a given point ([x], [y]).
  ///
  /// [dx] is the magnitude of the displacement along the x-axis and [dy] is
  /// the magnitude of the displacement along the y-axis.
  ///
  /// If [vx] and [vy] are not null, the velocity of the granule at ([x], [y])
  /// is set to [vx] and [vy] along the x and y axes respectively.
  /// If [vx] and [vy] are null, the velocity of the granule is set to
  /// [dx] and [dy] in the x and y axes respectively.
  ///
  /// A negative [x] / [y] is interpreted relative to the right/bottom edge of
  /// the grid.
  void displace({
    required int x,
    required int y,
    required double dx,
    required double dy,
    double? vx,
    double? vy
  });
}