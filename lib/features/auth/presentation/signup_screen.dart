import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/widgets/chat_text_button.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_title.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_subtitle.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:chitchat/features/auth/presentation/controllers/auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
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
                child: ListView(
                  children: [
                    AuthTitle(
                      title1: "Sign up",
                      title2: "with email",
                      containerWidth: 68.6,
                    ),
                    const SizedBox(height: 17),
                    AuthSubtitle(
                        subtitle:
                            "Get chatting with friends and family today by signing up for our chat app!"),
                    const SizedBox(height: 60),
                    AuthTextField(
                      controller: nameController,
                      labelText: "Your name",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field cannot be empty.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    AuthTextField(
                        controller: emailController,
                        labelText: "Your Email",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty.';
                          }
                          if (!EmailValidator.validate(value)) {
                            return "Invalid email format.";
                          }
                          return null;
                        }
                    ),
                    const SizedBox(height: 30),
                    AuthTextField(
                      controller: passwordController,
                      labelText: "Your Password",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field cannot be empty.';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    AuthTextField(
                      controller: confirmPasswordController,
                      labelText: "Confirm Password",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field cannot be empty.';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ChatTextButton(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        final auth = ref.read(authControllerProvider);

                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          Fluttertoast.showToast(msg: "Password not match");
                          return;
                        }

                        final errorMessage =
                            await auth.registerWithEmailAndPassword(
                          nameController.text,
                          emailController.text,
                          passwordController.text,
                        );

                        if (errorMessage == null) {
                          Fluttertoast.showToast(msg: "Sign up successfully");
                          context.go('/home');
                        } else {
                          Fluttertoast.showToast(msg: errorMessage);
                        }
                      }
                    },
                    text: "Sign up",
                    buttonColor: Colors.lightBlue,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
