import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';

import '../../components/controls/index.dart';

class BoundaryControl extends StatelessComponent {
  final MutableCell<bool> closed;

  const BoundaryControl({
    super.key,
    required this.closed
  });

  @override
  Component build(BuildContext context) {
    return fragment([
      label([
        text('Boundary'),
        Select(
          options: [false, true],
          selected: closed,
          builder: (context, closed) => text(
            closed ? 'Closed' : 'Open'
          )
        )
      ])
    ]);
  }
}