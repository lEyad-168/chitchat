import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/widgets/chat_text_button.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_title.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_subtitle.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:chitchat/features/auth/presentation/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: AuthBackButton(),
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      AuthTitle(
                          title1: "Sign in ",
                          title2: "to Chit Chat",
                          containerWidth: 65),
                      const SizedBox(height: 16),
                      AuthSubtitle(
                          subtitle:
                              "Welcome back! Sign in using your email to continue"),
                      const SizedBox(height: 30),
                      AuthTextField(
                        controller: emailController,
                        labelText: "Your Email",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      AuthTextField(
                        controller: passwordController,
                        labelText: "Your Password",
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ChatTextButton(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final auth = ref.read(authControllerProvider);
                          final errorMessage =
                              await auth.loginWithEmailAndPassword(
                                  emailController.text,
                                  passwordController.text);

                          if (errorMessage == null) {
                            Fluttertoast.showToast(msg: "Sign in successfully");
                            context.go('/home');
                          } else {
                            Fluttertoast.showToast(msg: errorMessage);
                          }
                        }
                      },
                      text: "Sign In",
                      buttonColor: Color(0xFF24786D),
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
