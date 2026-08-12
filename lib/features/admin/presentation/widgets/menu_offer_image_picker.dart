import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Dedicated image picker + upload widget for the Menu Offers form.
///
/// Unlike [KZImagePickerWidget] (which also accepts a pasted URL), this
/// never lets the admin type a URL — every image comes from the device
/// (gallery/camera) and goes through the real `POST /admin/uploads/image`
/// endpoint via the existing [menuRepositoryProvider]. Owns its own upload
/// lifecycle end to end (pick -> local preview -> auto-upload ->
/// success/error) and only ever reports a URL to the caller once the
/// upload has actually succeeded — editing any other form field never
/// touches this widget's state, so it never re-uploads on its own.
class MenuOfferImagePicker extends ConsumerStatefulWidget {
  /// The offer's current remote image (edit mode) — shown until the admin
  /// picks a replacement.
  final String? initialImageUrl;

  /// Fired only after a newly-picked image finishes uploading successfully.
  final ValueChanged<String> onUploaded;

  /// Fired whenever the busy/uploading state changes, so the parent form
  /// can disable Save while a new image is still in flight.
  final ValueChanged<bool> onUploadingChanged;

  const MenuOfferImagePicker({
    super.key,
    required this.initialImageUrl,
    required this.onUploaded,
    required this.onUploadingChanged,
  });

  @override
  ConsumerState<MenuOfferImagePicker> createState() =>
      _MenuOfferImagePickerState();
}

class _MenuOfferImagePickerState extends ConsumerState<MenuOfferImagePicker> {
  final _picker = ImagePicker();

  XFile? _localFile;
  Uint8List? _localBytes;
  bool _uploading = false;
  bool _hasError = false;

  bool get _hasAnyImage =>
      _localBytes != null || (widget.initialImageUrl?.isNotEmpty ?? false);

  Future<void> _pick(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (xFile == null) return;
      final bytes = await xFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _localFile = xFile;
        _localBytes = bytes;
        _hasError = false;
      });
      await _upload();
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _upload() async {
    final file = _localFile;
    final bytes = _localBytes;
    if (file == null || bytes == null) return;

    setState(() {
      _uploading = true;
      _hasError = false;
    });
    widget.onUploadingChanged(true);

    final repo = ref.read(menuRepositoryProvider);
    final result = await repo.uploadImage(bytes, file.name);

    if (!mounted) return;
    setState(() => _uploading = false);
    widget.onUploadingChanged(false);

    result.fold((failure) => setState(() => _hasError = true), (url) {
      setState(() => _hasError = false);
      widget.onUploaded(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: KZ.surfaceContainerLow,
            borderRadius: BorderRadius.circular(KZ.radiusLg),
            border: Border.all(
              color: _hasError
                  ? KZ.error.withValues(alpha: 0.5)
                  : _hasAnyImage
                  ? KZ.primaryContainer.withValues(alpha: 0.5)
                  : KZ.outlineVariant,
              width: _hasAnyImage || _hasError ? 2 : 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildPreviewArea(),
        ),
        const SizedBox(height: KZ.sp12),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.photo_library_rounded,
                label: 'menu_offers.choose_gallery'.tr(),
                onTap: _uploading ? null : () => _pick(ImageSource.gallery),
              ),
            ),
            if (!kIsWeb) ...[
              const SizedBox(width: KZ.sp8),
              Expanded(
                child: _actionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'menu_offers.take_photo'.tr(),
                  onTap: _uploading ? null : () => _pick(ImageSource.camera),
                ),
              ),
            ],
          ],
        ),
        if (_hasError) ...[
          const SizedBox(height: KZ.sp8),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: KZ.error,
                size: 16,
              ),
              const SizedBox(width: KZ.sp6),
              Expanded(
                child: Text(
                  'menu_offers.image_upload_error'.tr(),
                  style: const TextStyle(
                    color: KZ.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _upload,
                child: Text(
                  'common.retry'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewArea() {
    if (_uploading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (_localBytes != null) Image.memory(_localBytes!, fit: BoxFit.cover),
          Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_localBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_localBytes!, fit: BoxFit.cover),
          if (!_hasError)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: KZ.tertiary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      );
    }

    final existingUrl = widget.initialImageUrl;
    if (existingUrl != null && existingUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: existingUrl,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => const Center(
          child: CircularProgressIndicator(color: KZ.primary, strokeWidth: 2),
        ),
        errorWidget: (ctx, url, err) => Container(
          color: KZ.surfaceContainerLow,
          child: const Icon(
            Icons.broken_image_outlined,
            color: KZ.onSurfaceVariant,
            size: 32,
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KZ.primaryFixed.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: KZ.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: KZ.sp8),
          Text(
            'menu_offers.image_placeholder'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KZ.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: disabled
              ? KZ.surfaceContainerLow
              : KZ.primaryFixed.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(KZ.radiusMd),
          border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: disabled ? KZ.onSurfaceVariant : KZ.primary,
              size: 18,
            ),
            const SizedBox(width: KZ.sp6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: disabled ? KZ.onSurfaceVariant : KZ.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
