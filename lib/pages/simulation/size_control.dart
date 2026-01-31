import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';

import '../../util/extensions.dart';
import '../../components/controls/index.dart';
import '../../components/dialog/index.dart';
import '../../components/layout/index.dart';

/// Control for changing the size of the grid
class SizeControl extends CellComponent {
  /// Cell holding the size of the grid.
  final MutableCell<int> size;

  const SizeControl({
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final open = MutableCell(false);

    return fragment([
      _SizeDialog(
          open: open,
          size: size
      ),
      CellComponent.builder((_) {
        return label([text('Size: ${size()} \u00D7 ${size()}')]);
      }),
      button(
          onClick: () => open.value = true,
          [
            text('Change')
          ]
      )
    ]);
  }
}

/// Dialog for selecting a size.
class _SizeDialog extends CellComponent {
  /// Cell controlling whether the dialog is open or closed.
  final MutableCell<bool> open;

  /// Cell holding the size selected by the user.
  ///
  /// **NOTE**: The value of this cell is only set if the user, confirms the
  /// entered size.
  final MutableCell<int> size;

  const _SizeDialog({
    required this.open,
    required this.size
  });

  @override
  Component build(BuildContext context) {
    final resize = ActionCell();
    final selectedSize = MutableCell(0);

    ValueCell.watch(() {
      if (open()) {
        selectedSize.value = size.peek();
      }
    });

    resize.watch(() {
      size.value = selectedSize.peek();
    });

    return Dialog(
        open: open,
        [
          Form(
              method: FormMethod.dialog,
              submit: resize,
              [
                Column([
                  h1([text('Select Size')]),
                  strong([
                    text('The current simulation will be reset when the size is changed.')
                  ]),
                  IntegerField(
                      value: selectedSize,
                      required: true,
                      min: 5,
                      max: 1000,

                      title: 'Size'
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, [
                    button(
                        autofocus: true,
                        type: ButtonType.button,
                        onClick: () => open.value = false,

                        [text('Cancel')]
                    ),
                    button([text('Resize')])
                  ])
                ])
              ]
          )
        ]
    );
  }
}
