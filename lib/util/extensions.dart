import 'package:live_cells_core/live_cells_core.dart';

/// Extends action cells with the [watch] utility method.
extension WatchAction on ValueCell<void> {
  /// Register a watch function ([fn]) that is run when [this] cell is triggered.
  ///
  /// [fn] is only called when the value of this cell is updated after the
  /// watch function is registered. That is it is not called immediately on
  /// registration.
  CellWatcher watch(void Function() fn) => Watch((state) {
    observe();
    state.afterInit();
    fn();
  });
}
