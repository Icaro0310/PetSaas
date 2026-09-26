import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'qr_download_stub.dart' if (dart.library.html) 'qr_download_web.dart';

import '../../config/theme.dart';
import '../../core/models/pet_model.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/pet_face.dart';
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
  bool _artistic = true;

  Future<Uint8List> _capturePng() async {
    final boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _share() async {
    final bytes = await _capturePng();
    final name = 'qr_${widget.petId}.png';
    if (kIsWeb) {
      await Share.shareXFiles([
        XFile.fromData(bytes, name: name, mimeType: 'image/png'),
      ], text: 'Escaneie este QR Code se encontrar meu pet');
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$name';
    await File(path).writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(path),
    ], text: 'Escaneie este QR Code se encontrar meu pet');
  }

  Future<void> _download() async {
    final bytes = await _capturePng();
    final name = 'qr_${widget.petId}.png';
    if (kIsWeb) {
      await downloadBytesAsFile(bytes, name);
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$name';
    await File(path).writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('QR guardado em: $path')));
  }

  Future<void> _toggleLost(bool lost) async {
    await SupabaseService.client
        .from('pets')
        .update({
          'is_lost': lost,
          'lost_at': lost ? DateTime.now().toUtc().toIso8601String() : null,
        })
        .eq('id', widget.petId);
    ref.invalidate(petsProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedPetIdProvider.notifier).state = widget.petId;
    final pet = ref.watch(selectedPetProvider);

    if (pet == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final qrUrl = DeepLinkService.publicPetUrl(pet.qrCodeUuid ?? pet.id);

    // Retrato embutido: foto real do pet > sprite pixel-art da raca > fallback
    // por especie (caramelo/tabby). EC nivel H tolera ~30% de oclusao.
    final faceAsset =
        petFaceAsset(pet.breed) ??
        (pet.species == PetSpecies.cat ? 'orange-tabby' : 'srd-caramelo');
    final ImageProvider embedded = pet.photoUrl != null
        ? NetworkImage(pet.photoUrl!)
        : AssetImage('assets/pet_faces/$faceAsset.png');

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
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.pets),
                  label: Text('Com o pet'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.qr_code_2),
                  label: Text('Classico'),
                ),
              ],
              selected: {_artistic},
              onSelectionChanged: (s) =>
                  setState(() => _artistic = s.first),
            ),
            const SizedBox(height: 20),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_artistic) ...[
                      Text(
                        pet.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    QrImageView(
                      data: qrUrl,
                      version: QrVersions.auto,
                      size: 260,
                      gapless: true,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      embeddedImage: _artistic ? embedded : null,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(64, 64),
                      ),
                      eyeStyle: QrEyeStyle(
                        eyeShape: _artistic
                            ? QrEyeShape.circle
                            : QrEyeShape.square,
                        color: _artistic ? AppTheme.primaryDark : Colors.black,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: _artistic
                            ? QrDataModuleShape.circle
                            : QrDataModuleShape.square,
                        color: _artistic ? AppTheme.primary : Colors.black,
                      ),
                    ),
                    if (_artistic) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Estou perdido? Escaneie para avisar meu tutor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  pet.isLost
                      ? 'O pet esta marcado como perdido.'
                      : 'Ative se o pet estiver perdido.',
                ),
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
