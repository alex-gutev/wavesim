import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import '../circular_progress_indicator.dart';
import '../layout/index.dart';
import '../../webgpu/index.dart';

/// Retrieves a [GPUDevice].
///
/// This component checks whether WebGPU is supported by the browser, and if so
/// retrieves a [GPUDevice] and calls [builder], passing the [GPUDevice] to it,
/// in order to render the child component underneath this one.
///
/// If WebGPU is not supported, an error message is displayed instead and
/// [builder] is not called.
class WebGPUCheck extends CellComponent {
  final Component Function(BuildContext context, GPUDevice device) builder;

  const WebGPUCheck({
    super.key,
    required this.builder
  });

  @override
  Component build(BuildContext context) {
    if (!kIsWeb) {
      return const _LoadingNotice();
    }

    final gpu = window.navigator.gpu;

    final device = ValueCell.computed(() async {
      final adapter = await gpu?.requestAdapter().toDart;
      return await adapter?.requestDevice().toDart;
    });

    final ready = device.isCompleted();

    if (gpu == null) {
      return ErrorNotice(
          title: 'WebGPU not supported!',
          children: [
            p([
              text('WebGPU is not supported by your web browser.'),
            ]),
            p([
              text("To run Wavesim2D you'll have to switch to a browser "
                  'that supports WebGPU.')
            ])
          ]
      );
    }

    if (!ready) {
      return const _LoadingNotice();
    }

    // TODO: Handle and report errors thrown by device.awaited()

    final gpuDevice = device.awaited();

    if (gpuDevice == null) {
      return ErrorNotice(
          title: 'Could not retrieve WebGPU adapter!',
      );
    }

    return builder(context, gpuDevice);
  }

  @css
  static List<StyleRule> get styles => [
    css('.webgpu-notice').styles(
      height: 100.vh,
      width: 100.vw
    ),
    css('.webgpu-loading-indicator').styles(
      fontSize: 4.rem
    )
  ];
}

class _LoadingNotice extends StatelessComponent {
  const _LoadingNotice();

  @override
  Component build(BuildContext context) {
    return Column(
        classes: 'webgpu-notice',
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        [
          const CircularProgressIndicator(
              classes: 'webgpu-loading-indicator'
          ),
          p([
            h2([
              text('Loading Wavesim2D...')
            ])
          ])
        ]
    );
  }
}

class ErrorNotice extends StatelessComponent {
  final String title;
  final List<Component> children;

  const ErrorNotice({
    super.key,
    required this.title, 
    this.children = const []
  });
  
  @override
  Component build(BuildContext context) => Column(
    classes: 'webgpu-notice',
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    [
      h2([
        text(title)
      ]),
      ...children
    ]
  );
}