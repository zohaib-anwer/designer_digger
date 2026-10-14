import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/admin_service.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/Services/supabase_storage_service.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:flutter/material.dart';

/// Admin-only: uploads to Supabase `media` and updates Firestore `image`.
class ReplaceProductImageButton extends StatefulWidget {
  const ReplaceProductImageButton({
    super.key,
    required this.productId,
    this.compact = true,
    this.onReplaced,
  });

  final String productId;
  final bool compact;
  final ValueChanged<String>? onReplaced;

  @override
  State<ReplaceProductImageButton> createState() =>
      _ReplaceProductImageButtonState();
}

class _ReplaceProductImageButtonState extends State<ReplaceProductImageButton> {
  bool _uploading = false;

  Future<void> _replaceImage() async {
    if (_uploading) return;

    if (!await AdminService.isAdmin()) {
      if (mounted) {
        Utils.flushBarErrorMessage('Admin only', context);
      }
      return;
    }

    final picked = await SupabaseStorageService.pickImage();
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url = await SupabaseStorageService.uploadImage(
        picked,
        folder: 'products',
      );

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.products)
          .doc(widget.productId)
          .update({'image': url});

      widget.onReplaced?.call(url);
      if (mounted) {
        Utils.toastmessage('Image updated');
      }
    } catch (e) {
      if (mounted) {
        Utils.flushBarErrorMessage('Upload failed: $e', context);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _button() {
    if (widget.compact) {
      return Material(
        color: Colors.black54,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _uploading ? null : _replaceImage,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: _uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: whiteclr,
                    ),
                  )
                : const Icon(
                    Icons.upload,
                    size: 16,
                    color: whiteclr,
                  ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: _uploading ? null : _replaceImage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_uploading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: whiteclr,
                ),
              )
            else
              const Icon(Icons.upload, size: 18, color: whiteclr),
            const SizedBox(width: 8),
            Text(
              _uploading ? 'Uploading...' : 'Replace image',
              style: const TextStyle(
                color: whiteclr,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AdminService.isAdminStream(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }
        return _button();
      },
    );
  }
}
