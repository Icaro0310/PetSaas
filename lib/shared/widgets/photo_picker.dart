import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget que permite escolher uma foto da galeria ou câmera.
/// Retorna o caminho local do arquivo. Compressão é responsabilidade do caller.
class PhotoPicker extends StatefulWidget {
  final String? currentUrl;
  final String? localPath;
  final ValueChanged<String?> onChanged;
  final double size;

  const PhotoPicker({
    super.key,
    this.currentUrl,
    this.localPath,
    required this.onChanged,
    this.size = 120,
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final _picker = ImagePicker();
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _localPath = widget.localPath;
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() => _localPath = file.path);
      widget.onChanged(file.path);
    }
  }

  void _remove() {
    setState(() => _localPath = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (_localPath != null) {
      image = FileImage(File(_localPath!));
    } else if (widget.currentUrl != null) {
      image = NetworkImage(widget.currentUrl!);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showOptions(),
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: image,
            child: image == null
                ? Icon(Icons.pets, size: widget.size / 2.5, color: Colors.grey)
                : null,
          ),
        ),
        if (image != null)
          TextButton(onPressed: _remove, child: const Text('Remover foto')),
      ],
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camara'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
