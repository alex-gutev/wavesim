import 'package:live_cells_core/live_cells_core.dart';

part 'types.g.dart';

/// Integer vector
typedef VectorI = Vector<int>;

/// Real-valued vector
typedef VectorF = Vector<double>;

/// Represents a 2D vector holding values of type [T]
@CellExtension(mutable: true)
class Vector<T extends num> {
  final T x;
  final T y;

  const Vector({
    required this.x,
    required this.y
  });

  @override
  bool operator ==(Object other) => _$VectorEquals(this, other);

  @override
  int get hashCode => _$VectorHashCode(this);
}