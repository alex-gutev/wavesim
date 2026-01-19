import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:web/web.dart' as web;

import '../util/ref_element.dart';

/// Implementation of [Dialog] component for the browser environment.
class DialogImpl extends CellComponent {
  final MutableCell<bool> open;
  final List<Component> children;
  final MutableCell<String?>? result;
  final String? classes;

  const DialogImpl(this.children, {
    super.key,
    required this.open,
    required this.result,
    required this.classes
  });

  @override
  Component build(BuildContext context) {
    final element = MutableCell<web.Element?>(null);

    ValueCell.watch(() {
      final elem = element() as web.HTMLDialogElement?;

      if (elem != null) {
        if (open() && !elem.open) {
          elem.showModal();
        }
        else if (!open() && elem.open) {
          elem.close();
        }
      }
    });

    return RefElement(
        child: dialog(
          classes: classes,
          children,

          events: {
            'close': (e) => MutableCell.batch(() {
              open.value = false;
              result?.value = _getDialogResult(element.value);
            })

          }
        ),
        onElementReady: (elem) {
          element.value = elem;
        }
    );
  }

  String? _getDialogResult(web.Element? element) {
    final dialog = element as web.HTMLDialogElement?;
    return dialog?.returnValue;
  }
}