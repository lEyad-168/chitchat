import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_text_field.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_icon_button.dart';
import 'package:chitchat/features/chat/presentation/providers/show_send_message_icon_provider.dart';

class ChatInputField extends ConsumerStatefulWidget {
  final String chatId;
  const ChatInputField({required this.chatId, super.key});

  @override
  ConsumerState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  late final TextEditingController _chatTextFieldController;
  final FocusNode _focusNode = FocusNode();

  void _sendMessage(WidgetRef ref, BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final message = _chatTextFieldController.text.trim();
    if (message.isNotEmpty) {
      chatRepo.sendMessage(widget.chatId, message, false, false);
      _chatTextFieldController.clear();

      _focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();
    _chatTextFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _chatTextFieldController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: isDarkMode(ref, context)
            ? Border(
                top: BorderSide(
                  color: Color(0xFF192222),
                  width: 1,
                ),
              )
            : Border(
                top: BorderSide(
                  color: Color(0xFFEEFAF8),
                  width: 1,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            ChatIconButton(
              iconPath: Assets.icons.clip.path,
              onPressed: () => _pickMedia(ref),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ChatTextField(
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      ref
                          .read(showSendMessageIconProvider.notifier)
                          .update((state) => true);
                    } else {
                      ref
                          .read(showSendMessageIconProvider.notifier)
                          .update((state) => false);
                    }
                  },
                  onSubmitted: (text) {
                    _sendMessage(ref, context);
                    ref
                        .read(showSendMessageIconProvider.notifier)
                        .update((state) => false);
                  },
                  controller: _chatTextFieldController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(WidgetRef ref) async {
    // TODO: DOENS'T WORK IN WEB, FIX
    if (kIsWeb) {
      Fluttertoast.showToast(msg: "Not supported in web for now");
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    final pickedFileFormat = pickedFile?.path.split(".").last;

    if (pickedFile != null && pickedFileFormat == "mp4" ||
        pickedFileFormat == "jpg" ||
        pickedFileFormat == "png" ||
        pickedFileFormat == "jpeg") {
      context.push(
          '/send-media-confirmation/?chatId=${widget.chatId}&mediaPath=${pickedFile!.path}');
    } else {
      Fluttertoast.showToast(msg: 'invalid media format');
    }
  }
}
