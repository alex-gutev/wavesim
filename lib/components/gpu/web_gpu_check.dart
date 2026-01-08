import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:live_cells_core/live_cells_core.dart';
import 'package:live_cells_jaspr/live_cells_jaspr.dart';
import 'package:web/web.dart';

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
    final gpu = window.navigator.gpu;

    final device = ValueCell.computed(() async {
      final adapter = await gpu?.requestAdapter().toDart;
      return await adapter?.requestDevice().toDart;
    });

    final ready = device.isCompleted();

    if (gpu == null) {
      return strong([
        text('WebGPU not supported')
      ]);
    }

    if (!ready) {
      return strong([
        text('Loading...')
      ]);
    }

    // TODO: Handle and report errors thrown by device.awaited()

    final gpuDevice = device.awaited();

    if (gpuDevice == null) {
      return strong([
        text('Could not retrieve WebGPU adapter')
      ]);
    }

    return builder(context, gpuDevice);
  }
}