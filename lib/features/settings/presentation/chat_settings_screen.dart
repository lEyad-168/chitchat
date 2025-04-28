import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/settings/presentation/widgets/setting_button.dart';

class ChatSettingsScreen extends ConsumerStatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends ConsumerState<ChatSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: SvgPicture.asset(
              Assets.icons.backButton.path,
              colorFilter: ColorFilter.mode(
                themeMode == ThemeMode.light ? Colors.black : Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: Text(
            "Chat settings",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 20,
                ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ListView(
            children: [
              SettingButton(
                title: "Delete all private chats",
                subtitle:
                    "This will delete all private chats. This can't be undone",
                onTap: () async {
                  await _showDialog(
                    () {
                      try {
                        chatRepo.deleteAllPrivateChats();
                        Fluttertoast.showToast(
                          msg: "All private chats deleted",
                        );
                        context.pop();
                      } on Exception catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                      }
                    },
                    "Delete all private chats",
                    "You sure you want to delete all private chats? This can't be undone.",
                    "Cancel",
                    "Delete",
                  );
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode(ref, context) ? Colors.white : Colors.black,
                ),
              ),
              SettingButton(
                title: "Leave all groups",
                subtitle: "This can't be undone",
                onTap: () async {
                  await _showDialog(
                    () {
                      try {
                        chatRepo.leftAllGroupChats();
                        Fluttertoast.showToast(
                          msg: "You left all groups",
                        );
                        context.pop();
                      } on Exception catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                      }
                    },
                    "Leave all groups",
                    "You sure you want to leave all groups? This can't be undone.",
                    "Cancel",
                    "Leave",
                  );
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode(ref, context) ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDialog(
    Function submit,
    String title,
    String subtitle,
    String cancelText,
    String submitText,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                ),
          ),
          content: Text(
            subtitle,
            style: TextStyle(
              fontFamily: FontFamily.circular,
              color: Color(0xFF797C7B),
            ),
          ),
          actions: [
            TextButton(
              child: Text(cancelText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(submitText),
              onPressed: () => submit(),
            ),
          ],
        );
      },
    );
  }
}
