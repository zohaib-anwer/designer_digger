import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/admin_service.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/Services/supabase_storage_service.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:designerdigger/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddPromotions extends StatefulWidget {
  const AddPromotions({super.key});

  @override
  State<AddPromotions> createState() => _AddPromotionsState();
}

class _AddPromotionsState extends State<AddPromotions> {
  bool isLoading = false;
  XFile? singleImage;
  chooseImage() async {
    return await SupabaseStorageService.pickImage();
  }

  Future<void> uploadImage(XFile image) async {
    if (!await AdminService.isAdmin()) {
      if (mounted) {
        Utils.flushBarErrorMessage('Admin only', context);
      }
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final value = await SupabaseStorageService.uploadImage(
        image,
        folder: 'promotions',
      );
      await users.add({
        'image': value,
        'heading': headingController.text,
        'title': titleController.text,
        'subtitle': subtitleController.text,
        'uid': box.read('uid')
      });
      Utils.toastmessage("Banner Added");
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        Utils.flushBarErrorMessage(
            "failedtoaddpromotionbanner: $error", context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  final _formkey = GlobalKey<FormState>();
  CollectionReference users =
      FirebaseFirestore.instance.collection(FirestoreCollections.promotions);

  var titleController = TextEditingController();
  var subtitleController = TextEditingController();
  var headingController = TextEditingController();
  var categoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size sc = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
      stream: AdminService.isAdminStream(),
      builder: (context, adminSnapshot) {
        if (adminSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (adminSnapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Banner')),
            body: const Center(child: Text('Admin access required')),
          );
        }
        return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? darkbackgroundclr
          : whiteclr,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? darkbackgroundclr
            : whiteclr,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Add Products",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? whiteclr
                : blackclr,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Center(
                  child: InkWell(
                    onTap: () async {
                      singleImage = await chooseImage();
                      if (singleImage != null && singleImage!.path.isNotEmpty) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      height: sc.height / 4,
                      width: sc.width / 1.17,
                      decoration: BoxDecoration(
                          image: singleImage != null
                              ? DecorationImage(
                                  image: FileImage(File(singleImage!.path)),
                                )
                              : const DecorationImage(
                                  image: AssetImage(
                                    "assets/camera-simple-outline-icon-vector-19230878-removebg-preview.png",
                                  ),
                                ),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? darkbackgroundclr
                              : whiteclr,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: greyclr)),
                    ),
                  ),
                ),
                SizedBox(
                  height: sc.height * 0.05,
                ),
                SizedBox(
                  height: sc.height * 0.07,
                  width: sc.width / 1.17,
                  child: TextFormField(
                    controller: titleController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        Utils.flushBarErrorMessage(
                            "Please enter banner title", context);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Banner title",
                      filled: true,
                      fillColor: lonboardingclr.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: greyclr),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: greyclr),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: sc.height * 0.035,
                ),
                SizedBox(
                  height: sc.height * 0.07,
                  width: sc.width / 1.17,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        Utils.flushBarErrorMessage(
                            "Please enter banner heading", context);
                      }
                      return null;
                    },
                    controller: headingController,
                    decoration: InputDecoration(
                      labelText: "Banner heading",
                      filled: true,
                      fillColor: lonboardingclr.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: greyclr),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: greyclr),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: sc.height * 0.035,
                ),
                SizedBox(
                  height: sc.height * 0.07,
                  width: sc.width / 1.17,
                  child: TextFormField(
                    controller: subtitleController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        Utils.flushBarErrorMessage(
                            "Please enter banner subtitle", context);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Banner subtitle",
                      filled: true,
                      fillColor: lonboardingclr.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: greyclr),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: greyclr),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: sc.height * 0.15,
                ),
                InkWell(
                  onTap: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        isLoading = false;
                      });
                      if (titleController.text.isEmpty) {
                      } else if (headingController.text.isEmpty) {
                      } else if (subtitleController.text.isEmpty) {
                      } else {
                        uploadImage(singleImage!);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      height: sc.height * 0.07,
                      width: sc.width / 1.17,
                      decoration: BoxDecoration(
                        color: onboardingclr,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: whiteclr,
                              ),
                            )
                          : const Center(
                              child: Text(
                                "Add Banner",
                                style: TextStyle(
                                    color: whiteclr,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: sc.height * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
