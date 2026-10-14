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

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signin() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = credential.user!.uid;
      final existing = await UserProfileService.doc(uid).get();
      if (!existing.exists) {
        await UserProfileService.saveProfile(
          uid: uid,
          data: {
            'email': emailController.text.trim(),
            'uid': uid,
            'name': credential.user!.displayName ?? '',
            'isAdmin': false,
            'avatar':
                'https://www.lightsong.net/wp-content/uploads/2020/12/blank-profile-circle.png',
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }

      box.write('uid', uid);
      box.write('islogin', true);

      if (!mounted) return;
      Utils.toastmessage('Login Succesfully');
      GoRouter.of(context).go('/mainview');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Login failed. Please try again.';
      switch (e.code) {
        case 'invalid-email':
          message = 'Enter a valid email address.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for that user.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
      }
      Utils.flushBarErrorMessage(message, context);
    } catch (_) {
      if (!mounted) return;
      Utils.flushBarErrorMessage('Login failed. Please try again.', context);
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size sc = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: onboardingclr,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: sc.height / 2,
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
                      "Sign In",
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
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
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
                    Consumer<SecurePass>(
                      builder: (context, value, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                            controller: passwordController,
                            obscureText: !value.securepass,
                            decoration: InputDecoration(
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
                              hintText: "Enter password",
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
                        );
                      },
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                signin();
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
                                    "Sign in",
                                    style: TextStyle(
                                        color: whiteclr,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        GoRouter.of(context).go('/signup');
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: blackclr,
                          ),
                          children: [
                            TextSpan(
                              text: "SignUp",
                              style: TextStyle(
                                color: onboardingclr,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
