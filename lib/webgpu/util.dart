import 'package:http/http.dart' as http;

import 'types.dart';

/// Load a shader located at a given [url].
Future<GPUShaderModule> loadShader({
  required GPUDevice device,
  required Uri url
}) async {
  final response = await http.get(url);
  final code = response.body;

  return device.createShaderModule(
    ShaderDescriptor(
        label: 'Shader from $url',
        code: code
    )
  );
}