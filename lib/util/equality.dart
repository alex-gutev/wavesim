import 'package:collection/collection.dart';
import 'package:live_cells_core/live_cells_core.dart';

/// Annotate a property to use list equality and hash functions
const listField = DataField(
    equals: listEquals,
    hash: listHashCode
);

/// Compare two lists for equality
bool listEquals<T>(List<T> a, List<T> b) => const ListEquality().equals(a, b);

/// Compute the hash code of a list
int listHashCode<T>(List<T> o) => const ListEquality().hash(o);
