import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/user_profile_service.dart';
import 'package:designerdigger/Utilities/Provider/securepass.dart';
import 'package:designerdigger/Utilities/colors.dart';
import 'package:designerdigger/Utilities/utils.dart';
import 'package:designerdigger/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool isLoading = false;

  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> SignUp() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    String? createdUid;
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      createdUid = credential.user!.uid;
      debugPrint('Auth user created uid=$createdUid');

      final phone = '+92${phoneController.text.trim()}';

      await UserProfileService.saveProfile(
        uid: createdUid,
        data: {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'phonenumber': phone,
          'uid': createdUid,
          'isAdmin': false,
          'avatar':
              'https://www.lightsong.net/wp-content/uploads/2020/12/blank-profile-circle.png',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      box.write('uid', createdUid);
      box.write('name', nameController.text.trim());
      box.write('islogin', true);

      if (!mounted) return;
      Utils.toastmessage('Saved to digger_users');
      GoRouter.of(context).go('/profilepic');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      debugPrint('Auth signup failed: ${e.code} ${e.message}');
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/Password sign-in is disabled. Enable it in Firebase Console → Authentication → Sign-in method.';
          break;
        case 'invalid-email':
          message = 'Enter a valid email address.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check internet and try again.';
          break;
        default:
          message = e.message ?? 'Auth signup failed (${e.code})';
      }
      Utils.flushBarErrorMessage(message, context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint('Firestore profile save failed: ${e.code} ${e.message}');
      // Auth user may already exist even if Firestore write failed.
      if (createdUid != null) {
        box.write('uid', createdUid);
        box.write('name', nameController.text.trim());
        box.write('islogin', true);
      }
      if (e.code == 'permission-denied') {
        Utils.flushBarErrorMessage(
          'Auth user created, but Firestore RULES blocked digger_users. Update Rules in Firebase Console.',
          context,
        );
      } else {
        Utils.flushBarErrorMessage(
          'Auth user created, but digger_users save failed: ${e.code}',
          context,
        );
      }
      if (createdUid != null) {
        GoRouter.of(context).go('/profilepic');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Signup unexpected error: $e');
      Utils.flushBarErrorMessage(e.toString(), context);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size sc = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: onboardingclr,
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: sc.height / 8,
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: sc.width / 1.3,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 234, 228, 228),
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                        colors: authbackgroundcontainer,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: sc.height * 0.025,
                      ),
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: onboardingclr,
                          fontSize: 21.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: sc.height * 0.01,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 15),
                        child: TextFormField(
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Name",
                            hintStyle:
                                const TextStyle(fontWeight: FontWeight.w400),
                            contentPadding: const EdgeInsets.all(6),
                            fillColor: whiteclr,
                            filled: true,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 15),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter Email",
                            hintStyle:
                                const TextStyle(fontWeight: FontWeight.w400),
                            contentPadding: const EdgeInsets.all(6),
                            fillColor: whiteclr,
                            filled: true,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 15),
                        child: Row(
                          children: [
                            Container(
                              height: sc.height * 0.055,
                              width: sc.width * 0.12,
                              decoration: BoxDecoration(
                                color: whiteclr,
                                border: Border.all(color: greyclr),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Text("+92 "),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Enter a valid phone number';
                                  }
                                  if (!value.trim().startsWith('3')) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter Phone Number",
                                  hintStyle:
                                      TextStyle(fontWeight: FontWeight.w400),
                                  contentPadding: EdgeInsets.all(6),
                                  fillColor: whiteclr,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: greyclr),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: greyclr),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<SecurePass>(
                        builder: (context, value, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 15),
                            child: TextFormField(
                              obscureText: !value.securepass,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                } else if (value.length < 6) {
                                  return 'Please enter 6 digit password';
                                }
                                return null;
                              },
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: "Enter password",
                                suffixIcon: InkWell(
                                  onTap: () {
                                    value.setLoading();
                                  },
                                  child: Icon(
                                    value.securepass
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: value.securepass
                                        ? onboardingclr
                                        : greyclr,
                                  ),
                                ),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w400),
                                contentPadding: const EdgeInsets.all(6),
                                fillColor: whiteclr,
                                filled: true,
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
                          );
                        },
                      ),
                      SizedBox(height: sc.height * 0.02),
                      InkWell(
                        onTap: isLoading
                            ? null
                            : () async {
                                if (_formkey.currentState!.validate()) {
                                  await SignUp();
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Container(
                            height: sc.height * 0.07,
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
                                      "Sign Up",
                                      style: TextStyle(
                                          color: whiteclr,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: sc.height * 0.02),
                      InkWell(
                        onTap: () {
                          context.push('/signin');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: blackclr,
                            ),
                            children: [
                              TextSpan(
                                text: "SignIn",
                                style: TextStyle(
                                  color: onboardingclr,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sc.height * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
