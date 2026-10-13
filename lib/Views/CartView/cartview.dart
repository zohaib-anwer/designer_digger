import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:designerdigger/Views/jazzcash_payment/jazzcash_payment_screen.dart';
import 'package:designerdigger/main.dart';
import 'package:flutter/material.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late final Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();

    _usersStream = FirebaseFirestore.instance
        .collection('cartitems')
        .where('uid', isEqualTo: box.read('uid'))
        .snapshots();
  }

  /// Converts Firestore product price into a numeric PKR amount.
  ///
  /// New products should be saved as numbers, for example:
  /// productprice: 1400
  ///
  /// This also safely handles old String values such as:
  /// "1400"
  /// "Rs 1400"
  /// "$5"
  double _getPrice(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    String price = value.toString().trim();

    // Remove common currency text/symbols if an old value exists.
    price = price.replaceAll('Rs', '');
    price = price.replaceAll('PKR', '');
    price = price.replaceAll('\$', '');
    price = price.replaceAll(',', '');
    price = price.trim();

    return double.tryParse(price) ?? 0;
  }

  /// Formats the total without unnecessary decimal places.
  String _formatPrice(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }

  /// Deletes one cart item.
  Future<void> _deleteCartItem(
    BuildContext context,
    DocumentSnapshot data,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('cartitems')
          .doc(data.id)
          .delete();

      if (!mounted) return;

      Utils.toastmessage(
        '${data['productname']} item removed from cart',
      );
    } catch (error) {
      if (!mounted) return;

      Utils.flushBarErrorMessage(
        'Failed to remove item: $error',
        context,
      );
    }
  }

  /// This is the entry point for the actual JazzCash checkout.
  ///
  /// The actual JazzCash merchant request should be performed by a secure
  /// backend/Cloud Function. Merchant password and SecureHash must NOT be
  /// placed directly inside the Flutter application.
  Future<void> _startJazzCashPayment({
    required double totalAmount,
    required List<QueryDocumentSnapshot> cartItems,
  }) async {
    if (totalAmount <= 0) {
      Utils.toastmessage('Cart total is invalid');
      return;
    }

    // Payment screen par jao aur result ka wait karo
    final bool? isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JazzCashPaymentScreen(totalAmount: totalAmount),
      ),
    ) as bool?;

    if (isSuccess == true) {
      // --- YAHAN CART CLEAR HOGA ---
      try {
        // Firebase se sare cart items delete karo
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var item in cartItems) {
          batch.delete(item.reference);
        }
        await batch.commit();

        if (!mounted) return;
        Utils.toastmessage('Payment Successful! Cart Cleared');

        // Optional: Order history me save karna ho to yahan code add kar sakte ho

      } catch (e) {
        Utils.flushBarErrorMessage('Payment success but failed to clear cart: $e', context);
      }
    } else if (isSuccess == false) {
      Utils.toastmessage('Payment Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size sc = MediaQuery.of(context).size;

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? darkbackgroundclr : whiteclr,
      appBar: AppBar(
        title: const Text(
          "Items in Cart",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load cart items',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<QueryDocumentSnapshot> cartItems =
              snapshot.data?.docs ?? [];

          // Empty cart
          if (cartItems.isEmpty) {
            return const Center(
              child: Text(
                'No cartitems yet! Lets order',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          // Calculate total PKR.
          double totalAmount = 0;

          for (final item in cartItems) {
            final dynamic price = item['productprice'];
            totalAmount += _getPrice(price);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot data =
                          cartItems[index];

                      final double productPrice =
                          _getPrice(data['productprice']);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: sc.height / 5.8,
                                      width: sc.width / 3.5,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            data['image'],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        color: isDark
                                            ? ldarkbackgroundclr
                                            : lgreyclr,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          left: 12.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(
                                                left:
                                                    sc.height * 0.015,
                                              ),
                                              child: SizedBox(
                                                width:
                                                    sc.width / 2.1,
                                                child: Text(
                                                  data['productname'],
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                  maxLines: 2,
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                    fontSize: 17.5,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            SizedBox(
                                              height:
                                                  sc.height * 0.008,
                                            ),

                                            Padding(
                                              padding:
                                                  EdgeInsets.only(
                                                left:
                                                    sc.height * 0.015,
                                              ),
                                              child: Text(
                                                'Rs ${_formatPrice(productPrice)}',
                                                style:
                                                    const TextStyle(
                                                  fontSize: 17.5,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: yellowclr,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Positioned(
                              right: 0,
                              top: -8,
                              child: IconButton(
                                onPressed: () {
                                  _deleteCartItem(
                                    context,
                                    data,
                                  );
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Color.fromARGB(
                                    255,
                                    152,
                                    103,
                                    105,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  height: sc.height * 0.015,
                ),

                // Total
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Rs ${_formatPrice(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: yellowclr,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: sc.height * 0.018,
                ),

                // JazzCash Checkout
                InkWell(
                  onTap: totalAmount > 0
                      ? () {
                          _startJazzCashPayment(
                            totalAmount: totalAmount,
                            cartItems: cartItems,
                          );
                        }
                      : null,
                  child: Container(
                    height: sc.height * 0.075,
                    width: sc.width / 1.1,
                    decoration: BoxDecoration(
                      color: totalAmount > 0
                          ? buttonclr
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        "Pay with JazzCash",
                        style: TextStyle(
                          color: lgreyclr,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: sc.height * 0.02,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}