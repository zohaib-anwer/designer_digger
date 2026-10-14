import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/admin_service.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:designerdigger/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection(FirestoreCollections.diggerUsers)
      .where('uid', isEqualTo: box.read('uid'))
      .snapshots();

  static const String _defaultAvatar =
      'https://www.lightsong.net/wp-content/uploads/2020/12/blank-profile-circle.png';

  Widget _menuItem({
    required Size sc,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
            child: Row(
              children: [
                Icon(icon, size: sc.height * 0.04),
                10.pw,
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const Divider(color: greyclr),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size sc = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? darkbackgroundclr : whiteclr,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sc.width,
                color: onboardingclr,
                padding: EdgeInsets.only(
                  top: sc.height * 0.07,
                  bottom: sc.height * 0.03,
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _usersStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SizedBox.shrink();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: sc.height * 0.18,
                        child: const Center(
                          child: CircularProgressIndicator(color: whiteclr),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return SizedBox(
                        height: sc.height * 0.18,
                        child: const Center(
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(_defaultAvatar),
                          ),
                        ),
                      );
                    }

                    final data = docs.first;
                    final avatar = (data.data() as Map<String, dynamic>?)?['avatar']
                            ?.toString() ??
                        _defaultAvatar;
                    final name =
                        (data.data() as Map<String, dynamic>?)?['name']?.toString() ??
                            '';

                    final double avatarRadius = sc.height * 0.09;

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: SizedBox(
                          width: avatarRadius * 2 + 16,
                          height: avatarRadius * 2 + 16,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: lgreyclr,
                                backgroundImage: NetworkImage(
                                  avatar.isEmpty ? _defaultAvatar : avatar,
                                ),
                                onBackgroundImageError: (_, __) {},
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: whiteclr,
                                  elevation: 2,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      context.push(
                                        '/editprofileview',
                                        extra: name,
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.edit,
                                        color: blackclr,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: sc.height * 0.03),
              StreamBuilder<bool>(
                stream: AdminService.isAdminStream(),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.data != true) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _menuItem(
                        sc: sc,
                        icon: Icons.receipt_long_outlined,
                        title: 'Placed Orders',
                        onTap: () =>
                            GoRouter.of(context).push('/adminordersview'),
                      ),
                      _menuItem(
                        sc: sc,
                        icon: Icons.add_photo_alternate_outlined,
                        title: 'Add Promotions',
                        onTap: () =>
                            GoRouter.of(context).push('/addpromotionsview'),
                      ),
                      _menuItem(
                        sc: sc,
                        icon: Icons.add_photo_alternate_outlined,
                        title: 'Add Products',
                        onTap: () =>
                            GoRouter.of(context).push('/addproductsview'),
                      ),
                    ],
                  );
                },
              ),
              _menuItem(
                sc: sc,
                icon: Icons.shopping_cart_outlined,
                title: 'Shopping Cart',
                onTap: () => GoRouter.of(context).push('/cartview'),
              ),
              StreamBuilder<bool>(
                stream: AdminService.isAdminStream(),
                builder: (context, adminSnapshot) {
                  // Admins use "Placed Orders"; hide user "My Orders".
                  if (adminSnapshot.data == true) {
                    return const SizedBox.shrink();
                  }
                  return _menuItem(
                    sc: sc,
                    icon: Icons.local_shipping_outlined,
                    title: 'My Orders',
                    onTap: () => GoRouter.of(context).push('/myordersview'),
                  );
                },
              ),
              _menuItem(
                sc: sc,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                onTap: () => context.push('/darkview'),
              ),
              _menuItem(
                sc: sc,
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  box.write('islogin', false);
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  GoRouter.of(context).go('/signin');
                },
              ),
              SizedBox(height: sc.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
