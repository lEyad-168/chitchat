import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/core/theme/theme_provider.dart';

class OnBoardDivider extends ConsumerWidget {
  const OnBoardDivider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFCDD1D0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(
            " OR ",
            style: TextStyle(
              color: themeMode == ThemeMode.light
                  ? Color(0xFF797C7B)
                  : Color(0xFFD6E4E0),
              fontSize: 14,
              fontFamily: FontFamily.circular,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFCDD1D0),
          ),
        ),
      ],
    );
  }
}
