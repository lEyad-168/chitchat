import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class LoginIconButton extends ConsumerWidget {
  final String iconPath;
  final Function() onTap;
  const LoginIconButton(
      {required this.iconPath, required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      splashColor: Color(0xFF24786D).withAlpha(150),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFA8B0AF),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        width: 48,
        height: 48,
        child: SvgPicture.asset(iconPath),
      ),
    );
  }
}
