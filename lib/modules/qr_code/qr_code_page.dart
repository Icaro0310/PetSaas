import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/supabase_service.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/loading_button.dart';

class QrCodePage extends ConsumerStatefulWidget {
  final String petId;
  const QrCodePage({super.key, required this.petId});

  @override
  ConsumerState<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends ConsumerState<QrCodePage> {
  final _qrKey = GlobalKey();

  Future<String> _capturePng() async {
    final boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_${widget.petId}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _share() async {
    final path = await _capturePng();
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Escaneie este QR Code se encontrar meu pet',
    );
  }

  Future<void> _download() async {
    final path = await _capturePng();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR guardado em: $path')),
    );
  }

  Future<void> _toggleLost(bool lost) async {
    await SupabaseService.client.from('pets').update({
      'is_lost': lost,
      'lost_at': lost ? DateTime.now().toUtc().toIso8601String() : null,
    }).eq('id', widget.petId);
    ref.invalidate(petsProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedPetIdProvider.notifier).state = widget.petId;
    final pet = ref.watch(selectedPetProvider);

    if (pet == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final qrUrl = DeepLinkService.publicPetUrl(pet.qrCodeUuid ?? pet.id);

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              pet.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cole este QR na coleira. Quem encontrar seu pet escaneia e te avisa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: QrImageView(
                  data: qrUrl,
                  version: QrVersions.auto,
                  size: 260,
                  gapless: true,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: 'Compartilhar',
              icon: Icons.share,
              onPressed: _share,
            ),
            const SizedBox(height: 12),
            LoadingButton(
              label: 'Baixar para impressao',
              icon: Icons.download,
              onPressed: _download,
            ),
            const SizedBox(height: 28),
            Card(
              child: SwitchListTile(
                title: Text(
                  pet.isLost ? 'Marcar como encontrado' : 'Marcar como perdido',
                  style: TextStyle(
                      color: pet.isLost ? AppTheme.danger : null,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Text(pet.isLost
                    ? 'O pet esta marcado como perdido.'
                    : 'Ative se o pet estiver perdido.'),
                value: pet.isLost,
                onChanged: (v) => _toggleLost(v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
