import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/settings/presentation/widgets/setting_button.dart';

class SettingsFunctions extends ConsumerStatefulWidget {
  const SettingsFunctions({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SettingsFunctionsState();
}

class _SettingsFunctionsState extends ConsumerState<SettingsFunctions> {
  @override
  Widget build(BuildContext context) {
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;

    return ListView(
      children: [
        const SizedBox(height: 21),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/user-details/${currentUser.uid}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: StreamBuilder(
                stream: userRepo.getUserDetails(currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final user = snapshot.data;
                  return Row(
                    children: [
                      Hero(
                        tag: 'profilePic',
                        child: ChatProfilePic(
                          chatPhotoURL: user!.photoURL,
                          isOnline: false,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.name ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            snapshot.data!.statusMessage ?? '',
                            style: const TextStyle(
                              color: Color(0xFF797C7B),
                              fontSize: 12,
                              fontFamily: FontFamily.circular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Divider(
            height: 1,
            color: isDarkMode(ref, context)
                ? Color(0xFF2D2F2E)
                : Color(0xFFF5F6F6)),
        const SizedBox(height: 18),
        SettingButton(
          iconPath: Assets.icons.keys.path,
          title: "Account",
          subtitle: "Name, status message",
          onTap: () {
            context.push('/user-details/${currentUser.uid}');
          },
        ),
        SettingButton(
          iconPath: Assets.icons.message.path,
          title: "Chat",
          subtitle: "Delete chats, groups",
          onTap: () {
            context.push('/settings/chat-settings');
          },
        ),
        SettingButton(
          iconPath: Assets.icons.settings.path,
          title: "App",
          subtitle: "Theme, language",
          onTap: () {
            context.push('/settings/app-settings');
          },
        ),
      ],
    );
  }
}
