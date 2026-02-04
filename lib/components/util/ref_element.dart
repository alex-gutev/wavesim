import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

/// Signature of the element ready callback function.
///
/// The function is called with one argument, the underlying [web.Element]
/// that implements a [DomComponent].
typedef ElementReady = void Function(web.Element);

/// A component that allows the underlying HTML element to be referenced.
///
/// When the [child] component is inserted in the DOM, [onElementReady] is
/// called on the underlying [web.Element] that implements the component.
///
/// **NOTE**: In order for this to work [child] must be a [DomComponent] that
/// does not have its ID attribute set.
///
/// **NOTE**: This component may not be used on the server environment.
class RefElement extends StatefulComponent {
  /// The child component to insert in the DOM.
  ///
  /// This must either be a [DomComponent] or a component that consists of a
  /// single [DomComponent]. It may not be an empty component e.g `fragment([])`
  /// or `Component.empty()` and may not be a component that wraps multiple
  /// [DomComponent] e.g. `fragment([div(...), div(...), ...])`.
  ///
  /// **NOTE**: The ID attribute of the [DomComponent] must not be set.
  final Component child;

  /// Callback function that is called when the underlying DOM element has been
  /// retrieved.
  final ElementReady onElementReady;

  const RefElement({
    super.key,
    required this.onElementReady,
    required this.child
  });

  @override
  State<StatefulComponent> createState() =>
      _RefElementState();
}

class _RefElementState extends State<RefElement> {
  /// Element ID counter
  static var _idCounter = 0;

  /// Element ID
  final String _id = '_refElement${_idCounter++}';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      context.binding.addPostFrameCallback(() {
        final element = web.document.getElementById(_id);

        if (element != null) {
          component.onElementReady(element);
        }
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return Component.wrapElement(
        id: _id,
        child: component.child
    );
  }
}