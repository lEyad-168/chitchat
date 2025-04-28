import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';

class OnBoardAppbar extends ConsumerWidget {
  const OnBoardAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'CHIT CHAT',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 23,
            fontFamily: FontFamily.circular,
          ),
        ),
      ],
    );
  }
}
