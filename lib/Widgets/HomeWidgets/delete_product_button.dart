import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/admin_service.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:flutter/material.dart';

/// Admin-only: deletes a product document from Firestore.
class DeleteProductButton extends StatefulWidget {
  const DeleteProductButton({
    super.key,
    required this.productId,
    this.productName,
    this.compact = true,
    this.onDeleted,
  });

  final String productId;
  final String? productName;
  final bool compact;
  final VoidCallback? onDeleted;

  @override
  State<DeleteProductButton> createState() => _DeleteProductButtonState();
}

class _DeleteProductButtonState extends State<DeleteProductButton> {
  bool _deleting = false;

  Future<void> _confirmAndDelete() async {
    if (_deleting) return;

    if (!await AdminService.isAdmin()) {
      if (mounted) {
        Utils.flushBarErrorMessage('Admin only', context);
      }
      return;
    }

    final name = (widget.productName ?? 'this product').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Remove "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _deleting = true);
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.products)
          .doc(widget.productId)
          .delete();

      widget.onDeleted?.call();
      if (mounted) {
        Utils.toastmessage('Product deleted');
      }
    } catch (e) {
      if (mounted) {
        Utils.flushBarErrorMessage('Delete failed: $e', context);
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Widget _button() {
    if (widget.compact) {
      return Material(
        color: Colors.red.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _deleting ? null : _confirmAndDelete,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: _deleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: whiteclr,
                    ),
                  )
                : const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: whiteclr,
                  ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: _deleting ? null : _confirmAndDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_deleting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: whiteclr,
                ),
              )
            else
              const Icon(Icons.delete_outline, size: 18, color: whiteclr),
            const SizedBox(width: 8),
            Text(
              _deleting ? 'Deleting...' : 'Delete product',
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
