import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../controls/index.dart';

/// Displays controls for the [frequency] and [phase] of a wave source.
class FrequencyControls extends CellComponent {
  /// Cell holding the [frequency]
  final MutableCell<num> frequency;

  /// Cell holding the [phase]
  final MutableCell<num> phase;

  /// Cell holding the number of time steps for which the source is kept.
  final MutableCell<int?> maxSteps;

  /// Is an existing source being edited or a new source being added?
  final bool isEdit;

  const FrequencyControls({
    required this.frequency,
    required this.phase,
    required this.maxSteps,
    this.isEdit = false
  });

  @override
  Component build(BuildContext context) {
    final isPulse = MutableCell.computed(() => maxSteps() == 1, (pulse) {
      maxSteps.value = pulse ? 1 : null;
    });

    return fragment([
      if (!isEdit)
        Checkbox(
            checked: isPulse,
            trailing: text('Pulse')
        ),
      NumField(
          title: 'Frequency',
          value: frequency,
          min: 0,
          enabled: !isPulse()
      ),
      NumField(
        title: 'Phase',
        value: phase,
      )
    ]);
  }
}