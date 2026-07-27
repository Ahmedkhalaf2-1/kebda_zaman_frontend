import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// A reusable image picker widget that handles:
/// - Picking from Gallery (works on Web, Android, iOS)
/// - Picking from Camera (Android / iOS)
/// - Falling back to URL input
/// - Previewing the selected image
///
/// [onImageSelected] is called with the [XFile] that was picked.
/// [onUrlChanged] is called when the user types/pastes a URL.
class KZImagePickerWidget extends StatefulWidget {
  final String? currentImageUrl;
  final ValueChanged<XFile> onImageSelected;
  final ValueChanged<String> onUrlChanged;

  const KZImagePickerWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    required this.onUrlChanged,
  });

  @override
  State<KZImagePickerWidget> createState() => _KZImagePickerWidgetState();
}

class _KZImagePickerWidgetState extends State<KZImagePickerWidget> {
  final _picker = ImagePicker();
  final _urlCtrl = TextEditingController();

  XFile? _pickedFile;
  Uint8List? _pickedBytes; // for Web preview

  @override
  void initState() {
    super.initState();
    _urlCtrl.text = widget.currentImageUrl ?? '';
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (xFile != null) {
        final bytes = await xFile.readAsBytes();
        setState(() {
          _pickedFile = xFile;
          _pickedBytes = bytes;
          _urlCtrl.clear();
        });
        widget.onImageSelected(xFile);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    if (kIsWeb) {
      // Camera not supported on Web — use gallery instead
      await _pickFromGallery();
      return;
    }
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (xFile != null) {
        final bytes = await xFile.readAsBytes();
        setState(() {
          _pickedFile = xFile;
          _pickedBytes = bytes;
          _urlCtrl.clear();
        });
        widget.onImageSelected(xFile);
      }
    } catch (e) {
      debugPrint('Camera pick error: $e');
    }
  }

  void _clearImage() {
    setState(() {
      _pickedFile = null;
      _pickedBytes = null;
      _urlCtrl.clear();
    });
    widget.onUrlChanged('');
  }

  bool get _hasPickedFile => _pickedFile != null && _pickedBytes != null;
  bool get _hasUrlImage => _urlCtrl.text.trim().isNotEmpty;
  bool get _hasImage => _hasPickedFile || _hasUrlImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Preview Area ───────────────────────────────────
        Container(
          width: double.infinity,
          height: _hasImage ? 180 : 130,
          decoration: BoxDecoration(
            color: KZ.surfaceContainerLow,
            borderRadius: BorderRadius.circular(KZ.radiusLg),
            border: Border.all(
              color: _hasImage
                  ? KZ.primaryContainer.withOpacity(0.4)
                  : KZ.outlineVariant,
              width: _hasImage ? 2 : 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _hasImage ? _buildPreview() : _buildUploadPlaceholder(),
        ),
        const SizedBox(height: KZ.sp12),

        // ── Action Buttons ─────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _actionBtn(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: _pickFromGallery,
              ),
            ),
            const SizedBox(width: KZ.sp8),
            if (!kIsWeb) ...[
              Expanded(
                child: _actionBtn(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: _pickFromCamera,
                ),
              ),
              const SizedBox(width: KZ.sp8),
            ],
            if (_hasImage)
              _iconBtn(Icons.delete_outline_rounded, KZ.error, _clearImage),
          ],
        ),
        const SizedBox(height: KZ.sp12),

        // ── URL Fallback ────────────────────────────────────
        const Text(
          'Or paste an image URL:',
          style: TextStyle(
            fontSize: 12,
            color: KZ.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: KZ.sp6),
        TextField(
          controller: _urlCtrl,
          decoration: KZ.inputDecoration(
            label: 'Image URL (https://...)',
            prefixIcon: const Icon(
              Icons.link_rounded,
              color: KZ.primary,
              size: 20,
            ),
          ),
          onChanged: (val) {
            setState(() {
              if (val.trim().isNotEmpty) {
                _pickedFile = null;
                _pickedBytes = null;
              }
            });
            widget.onUrlChanged(val.trim());
          },
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Show picked file bytes (web-compatible)
        if (_hasPickedFile)
          Image.memory(_pickedBytes!, fit: BoxFit.cover)
        else if (_hasUrlImage)
          CachedNetworkImage(
            imageUrl: _urlCtrl.text.trim(),
            fit: BoxFit.cover,
            placeholder: (ctx, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (ctx, url, err) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.orange, size: 36),
                SizedBox(height: 6),
                Text(
                  'Invalid URL',
                  style: TextStyle(color: KZ.secondary, fontSize: 12),
                ),
              ],
            ),
          ),

        // "Change" overlay button
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.sp10,
                vertical: KZ.sp6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(KZ.radiusFull),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: KZ.primaryFixed.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_outlined,
            color: KZ.primaryContainer,
            size: 30,
          ),
        ),
        const SizedBox(height: KZ.sp8),
        const Text(
          'Upload Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: KZ.primary,
          ),
        ),
        const SizedBox(height: KZ.sp4),
        Text(
          kIsWeb
              ? 'Browse file or paste URL below'
              : 'Gallery · Camera · or URL below',
          style: const TextStyle(fontSize: 11, color: KZ.secondary),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: KZ.primaryFixed.withOpacity(0.5),
          borderRadius: BorderRadius.circular(KZ.radiusMd),
          border: Border.all(color: KZ.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: KZ.primary, size: 18),
            const SizedBox(width: KZ.sp6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KZ.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: KZ.errorContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(KZ.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
