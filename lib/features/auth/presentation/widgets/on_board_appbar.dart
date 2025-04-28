import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';

class OnBoardAppbar extends ConsumerWidget {
  const OnBoardAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          Assets.icons.logoForBlackBack.path,
          width: 16,
          height: 19.2,
        ),
        const SizedBox(width: 6),
        Text(
          'Chit Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: FontFamily.circular,
          ),
        ),
      ],
    );
  }
}
