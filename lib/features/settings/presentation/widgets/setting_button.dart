import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SettingButton extends ConsumerWidget {
  final String? iconPath;
  final String? imagePath;
  final String title;
  final TextStyle? titleStyle;
  final String subtitle;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final Function()? onTap;
  const SettingButton(
      {this.iconPath,
      this.imagePath,
      this.titleStyle,
      this.subtitleStyle,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.trailing,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Row(
            children: [
              if (iconPath != null || imagePath != null)
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: iconPath != null
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: SvgPicture.asset(
                            iconPath!,
                            colorFilter: ColorFilter.mode(
                              Color(0xFF797C7B),
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(imagePath!),
                        ),
                ),
              if (iconPath != null || imagePath != null)
                const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle ??
                        Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 16,
                            ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: subtitleStyle ??
                        Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                            ),
                  ),
                ],
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
