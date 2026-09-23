import 'dart:typed_data';

/// Stub para plataformas nativas: o download via browser so existe na Web.
Future<void> downloadBytesAsFile(Uint8List bytes, String filename) {
  throw UnsupportedError('Download via browser so e suportado na Web');
}
