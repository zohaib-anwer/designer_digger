import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

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

  @override
  Widget build(BuildContext context) {
    final Size sc = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String uid = box.read('uid')?.toString() ?? '';

    return Scaffold(
      backgroundColor: isDark ? darkbackgroundclr : whiteclr,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: uid.isEmpty
          ? const Center(child: Text('Please sign in to view orders'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreCollections.orders)
                  .where('uid', isEqualTo: uid)
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

                final orders = [...(snapshot.data?.docs ?? [])];
                orders.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>?)?['createdAt'];
                  final bTime = (b.data() as Map<String, dynamic>?)?['createdAt'];
                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }
                  if (aTime is Timestamp) return -1;
                  if (bTime is Timestamp) return 1;
                  return 0;
                });

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final data =
                        orders[index].data() as Map<String, dynamic>? ?? {};
                    final items = (data['items'] as List<dynamic>? ?? [])
                        .whereType<Map>()
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList();
                    final status = (data['status'] ?? 'placed').toString();
                    final totalAmount = data['totalAmount'];
                    final createdAt = data['createdAt'] as Timestamp?;
                    final firstImage = items.isNotEmpty
                        ? (items.first['image'] ?? '').toString()
                        : '';
                    final itemLabel = items.length == 1
                        ? (items.first['productname'] ?? '1 item').toString()
                        : '${items.length} items';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? ldarkbackgroundclr : lgreyclr,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: firstImage.isEmpty
                                ? Container(
                                    height: 62,
                                    width: 62,
                                    color: greyclr.withValues(alpha: 0.3),
                                    child: const Icon(Icons.receipt_long),
                                  )
                                : Image.network(
                                    firstImage,
                                    height: 62,
                                    width: 62,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 62,
                                      width: 62,
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15.5,
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
                                        color: _statusColor(status)
                                            .withValues(alpha: 0.18),
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
                                SizedBox(height: sc.height * 0.005),
                                Text(
                                  _formatDate(createdAt),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: greyclr,
                                  ),
                                ),
                                SizedBox(height: sc.height * 0.004),
                                Text(
                                  'Rs ${_formatPrice(totalAmount)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: yellowclr,
                                  ),
                                ),
                              ],
                            ),
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
