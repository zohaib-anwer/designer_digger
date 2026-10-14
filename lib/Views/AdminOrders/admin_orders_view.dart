import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/admin_service.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  static const List<String> _statuses = [
    'placed',
    'confirmed',
    'completed',
    'cancelled',
  ];

  String _formatPrice(dynamic value) {
    if (value == null) return '0';
    if (value is num) {
      final amount = value.toDouble();
      if (amount == amount.roundToDouble()) {
        return amount.toInt().toString();
      }
      return amount.toStringAsFixed(2);
    }
    return value.toString();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return greenclr;
      case 'cancelled':
        return Colors.redAccent;
      case 'placed':
      default:
        return yellowclr;
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    if (!await AdminService.isAdmin()) {
      if (!mounted) return;
      Utils.flushBarErrorMessage('Admin only', context);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.orders).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Utils.toastmessage('Order marked as $status');
    } catch (error) {
      if (!mounted) return;
      Utils.flushBarErrorMessage('Failed to update order: $error', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size sc = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? darkbackgroundclr : whiteclr,
      appBar: AppBar(
        title: const Text(
          'Placed Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.orders)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load orders.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No orders placed yet',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final items = (data['items'] as List<dynamic>? ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
              final status = (data['status'] ?? 'placed').toString();
              final userName = (data['userName'] ?? 'Customer').toString();
              final userEmail = (data['userEmail'] ?? '').toString();
              final userPhone = (data['userPhone'] ?? '').toString();
              final paymentMethod =
                  (data['paymentMethod'] ?? 'JazzCash').toString();
              final totalAmount = data['totalAmount'];
              final createdAt = data['createdAt'] as Timestamp?;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? ldarkbackgroundclr : lgreyclr,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userName.isEmpty ? 'Customer' : userName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sc.height * 0.006),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: greyclr,
                      ),
                    ),
                    if (userEmail.isNotEmpty) ...[
                      SizedBox(height: sc.height * 0.004),
                      Text(
                        userEmail,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                    if (userPhone.isNotEmpty) ...[
                      SizedBox(height: sc.height * 0.004),
                      Text(
                        userPhone,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                    const Divider(height: 22),
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                (item['image'] ?? '').toString(),
                                height: 58,
                                width: 58,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 58,
                                  width: 58,
                                  color: greyclr.withValues(alpha: 0.3),
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (item['productname'] ?? 'Item').toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs ${_formatPrice(item['productprice'])}',
                                    style: const TextStyle(
                                      color: yellowclr,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          paymentMethod,
                          style: const TextStyle(
                            fontSize: 13,
                            color: greyclr,
                          ),
                        ),
                        Text(
                          'Rs ${_formatPrice(totalAmount)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: yellowclr,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sc.height * 0.012),
                    DropdownButtonFormField<String>(
                      key: ValueKey('${doc.id}-$status'),
                      initialValue:
                          _statuses.contains(status) ? status : 'placed',
                      decoration: InputDecoration(
                        labelText: 'Update status',
                        filled: true,
                        fillColor: isDark ? darkbackgroundclr : whiteclr,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _statuses
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null || value == status) return;
                        _updateStatus(doc.id, value);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
