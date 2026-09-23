import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Download de bytes como ficheiro no browser (AnchorElement + object URL).
Future<void> downloadBytesAsFile(Uint8List bytes, String filename) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  try {
    web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..click();
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
