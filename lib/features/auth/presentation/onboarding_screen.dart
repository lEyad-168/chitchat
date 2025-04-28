import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/core/widgets/chat_text_button.dart';
import 'package:chitchat/features/auth/presentation/widgets/on_board_appbar.dart';
import 'package:chitchat/features/auth/presentation/widgets/on_board_divider.dart';
import 'package:chitchat/features/auth/presentation/widgets/on_board_subtitle.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 30),
        child: Stack(
          children: [
            Positioned(
              child: Image(
                image: AssetImage('assets/background/elipse.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          OnBoardAppbar(),
                          const SizedBox(height: 40),
                          AutoSizeText(
                            "Connect friends easily & quickly",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 68,
                                height: 1.2,
                                fontFamily: FontFamily.caros),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),
                          OnBoardSubtitle(),
                          const SizedBox(height: 60),
                          ChatTextButton(
                            onTap: () => context.push('/login'),
                            text: "Sign in",
                            buttonColor: Colors.white,
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: 20),
                          OnBoardDivider(),
                          const SizedBox(height: 20),
                          ChatTextButton(
                            onTap: () => context.push('/signup'),
                            text: "Sign Up",
                            buttonColor: Colors.white,
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
