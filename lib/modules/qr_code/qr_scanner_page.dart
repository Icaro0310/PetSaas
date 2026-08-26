import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/services/analytics_service.dart';

/// Scanner de QR Code. Le o QR da coleira do pet e abre a pagina publica.
/// Usado por quem encontra um pet perdido.
class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  final _controller = MobileScannerController();
  bool _navigated = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_navigated) return;
    final barcode = capture.barcodes.firstOrNull;
    final url = barcode?.rawValue;
    if (url == null) return;

    // Extrai o uuid da URL publica: .../p/<uuid> ou .../pet/<uuid>
    String? uuid;
    final pIdx = url.indexOf('/p/');
    final petIdx = url.indexOf('/pet/');
    if (pIdx != -1) {
      uuid = url.substring(pIdx + 3);
    } else if (petIdx != -1) {
      uuid = url.substring(petIdx + 5);
    } else {
      // Assume que o valor lido e o proprio uuid
      uuid = url;
    }
    // Limpa query params
    uuid = uuid.split('?').first.split('/').first;

    if (uuid.isEmpty) return;
    _navigated = true;
    AnalyticsService.qrScanned();
    context.go('${AppRoutes.publicPet}/$uuid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR do pet')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Aponte a camara para o QR Code da coleira',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
