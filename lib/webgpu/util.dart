import 'dart:typed_data' as types;
import 'package:universal_web/js_interop.dart';

import 'types.dart';

/// Utility methods for creating buffers
extension CreateBufferExtension on GPUDevice {
  /// Create a uint32 buffer.
  ///
  /// The buffer contents are initialized to [data].
  ///
  /// [usage] is a [$GPUBufferUsage] bitmask describing how the buffer is
  /// intended to be used.
  GPUBuffer makeUint32Buffer({
    required types.Uint32List data,
    required int usage
  }) {
    final buffer = createBuffer(
        BufferDescriptor(
            size: data.lengthInBytes,
            usage: usage,
            mappedAtCreation: true
        )
    );

    final view = types.Uint32List.view(buffer.getMappedRange().toDart);
    view.setAll(0, data);

    buffer.unmap();
    return buffer;
  }

  /// Create a float32 buffer.
  ///
  /// The buffer contents are initialized to [data].
  ///
  /// [usage] is a [$GPUBufferUsage] bitmask describing how the buffer is
  /// intended to be used.
  GPUBuffer makeFloat32Buffer({
    required types.Float32List data,
    required int usage
  }) {
    final buffer = createBuffer(
        BufferDescriptor(
            size: data.lengthInBytes,
            usage: usage,
            mappedAtCreation: true
        )
    );

    final view = types.Float32List.view(buffer.getMappedRange().toDart);
    view.setAll(0, data);

    buffer.unmap();
    return buffer;
  }
}