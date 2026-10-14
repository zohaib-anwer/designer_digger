import 'dart:io';

import 'package:designerdigger/Services/user_profile_service.dart';
import 'package:designerdigger/Services/supabase_storage_service.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:designerdigger/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class Profilepic extends StatefulWidget {
  const Profilepic({super.key});

  @override
  State<Profilepic> createState() => _ProfilepicState();
}

class _ProfilepicState extends State<Profilepic> {
  bool isLoading = false;
  XFile? singleImage;

  Future<void> chooseImage() async {
    singleImage = await SupabaseStorageService.pickImage();
    if (singleImage != null && singleImage!.path.isNotEmpty && mounted) {
      setState(() {});
    }
  }

  Future<void> _finish({String? avatarUrl}) async {
    final uid = box.read('uid')?.toString() ?? '';
    if (uid.isEmpty) {
      Utils.flushBarErrorMessage('User id missing. Sign up again.', context);
      return;
    }

    if (!isLoading && mounted) {
      setState(() => isLoading = true);
    }
    try {
      await UserProfileService.saveProfile(
        uid: uid,
        data: {
          'avatar': avatarUrl ??
              'https://www.lightsong.net/wp-content/uploads/2020/12/blank-profile-circle.png',
        },
      );
      box.write('islogin', true);
      if (!mounted) return;
      Utils.toastmessage('SignUp successfully');
      GoRouter.of(context).go('/mainview');
    } catch (e) {
      if (!mounted) return;
      Utils.flushBarErrorMessage(
        'Could not save digger_users: $e',
        context,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _uploadAndFinish() async {
    if (singleImage == null) {
      Utils.flushBarErrorMessage('Please select an image first', context);
      return;
    }
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final url = await SupabaseStorageService.uploadImage(
        singleImage!,
        folder: 'avatars',
      );
      await _finish(avatarUrl: url);
    } catch (e) {
      if (!mounted) return;
      Utils.flushBarErrorMessage('Upload failed: $e', context);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size sc = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: onboardingclr,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: sc.height * 0.1),
              InkWell(
                onTap: isLoading ? null : chooseImage,
                child: Container(
                  height: sc.height / 3,
                  width: sc.width / 2,
                  decoration: BoxDecoration(
                    color: whiteclr,
                    shape: BoxShape.circle,
                    image: singleImage != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(singleImage!.path)),
                          )
                        : const DecorationImage(
                            image: NetworkImage(
                              'https://www.lightsong.net/wp-content/uploads/2020/12/blank-profile-circle.png',
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: sc.height * 0.3),
              InkWell(
                onTap: isLoading ? null : () => _finish(),
                child: Container(
                  height: sc.height * 0.07,
                  width: sc.width / 1.25,
                  decoration: BoxDecoration(
                    color: lonboardingclr,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: whiteclr)
                        : const Text(
                            'Skip',
                            style: TextStyle(
                              color: whiteclr,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: sc.height * 0.05),
              InkWell(
                onTap: isLoading ? null : _uploadAndFinish,
                child: Container(
                  height: sc.height * 0.07,
                  width: sc.width / 1.25,
                  decoration: BoxDecoration(
                    color: whiteclr,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: onboardingclr,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sc.height * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
