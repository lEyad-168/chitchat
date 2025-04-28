import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/features/chat/data/dto/chat_dto.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/users/domain/user_repository_interface.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:chitchat/features/chat/presentation/utils/calculate_time_since_last_message.dart';

class ChatList extends ConsumerWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatRepositoryProvider);
    final user = ref.watch(currentUserProvider).asData?.value;
    final userProvider = ref.watch(userRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: StreamBuilder(
        stream: chats.getChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }

          final data = snapshot.data;
          if (data!.isEmpty) {
            return Center(
              child: Text(
                "No chats yet",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 24,
                    ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "My Chats",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final chat = data[index];

                    final unseenMessagesCount =
                        ref.watch(unreadMessagesProvider(chat.id!));

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push('/chat/${chat.id}');
                        },
                        highlightColor: Colors.transparent,
                        child: chatButton(chats, chat, userProvider, user!,
                            unseenMessagesCount, context, ref),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget chatButton(
    ChatRepositoryInterface chats,
    ChatDTO chat,
    UserRepositoryInterface userProvider,
    User user,
    AsyncValue<int> unseenMessagesCount,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.15,
        children: [
          IconButton(
            icon: SvgPicture.asset(Assets.icons.trash.path, width: 22),
            padding: const EdgeInsets.all(7),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Delete chat",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 24,
                          ),
                    ),
                    content: Text(
                      "Are you sure you want to delete this chat?",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FilledButton(
                        child: Text("Delete"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          chats.deleteChat(chat.id!);
                          Fluttertoast.showToast(msg: 'Chat deleted!');
                        },
                      ),
                    ],
                  );
                },
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Color(0xFFEA3736)),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: chats.getChatPhotoURL(chat, userProvider),
              builder: (context, snapshot) {
                final chatPhoto = snapshot.data;
                final hasValidPhoto = chatPhoto != null && chatPhoto.isNotEmpty;

                if (chat.type == 'private') {
                  final friendId = chat.participants!
                      .firstWhere((id) => id != user.uid, orElse: () => '');
                  final friendDetails = userProvider.getUserDetails(friendId);
                  return StreamBuilder(
                    stream: friendDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final friend = snapshot.data;
                      return ChatProfilePic(
                        chatPhotoURL: hasValidPhoto ? chatPhoto : null,
                        isOnline: friend!.isOnline ?? false,
                      );
                    },
                  );
                } else {
                  return ChatProfilePic(
                    chatPhotoURL: hasValidPhoto ? chatPhoto : null,
                    isOnline: false,
                  );
                }
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: _getChatTitle(chat, user.uid, userProvider),
                      builder: (context, snapshot) {
                        final chatTitle = snapshot.data;
                        return Text(
                          chatTitle ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 20,
                                  ),
                        );
                      }),
                  const SizedBox(height: 6),
                  if (chat.lastMessage == null)
                    Text(
                      "No message yet",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFF797C7B),
                        fontSize: 12,
                        fontFamily: FontFamily.circular,
                      ),
                    )
                  else if (chat.lastMessage!.messageType == 'text')
                    Text(
                      chat.lastMessage != null
                          ? chat.lastMessage!.text ?? ''
                          : "No message yet",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFF797C7B),
                        fontSize: 12,
                        fontFamily: FontFamily.circular,
                      ),
                    )
                  else if (chat.lastMessage!.messageType == 'image')
                    Row(
                      children: [
                        Icon(Icons.image, color: Color(0xFF797C7B), size: 16),
                        const SizedBox(width: 5),
                        Text(
                          "Image",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Color(0xFF797C7B),
                            fontSize: 12,
                            fontFamily: FontFamily.circular,
                          ),
                        )
                      ],
                    )
                  else if (chat.lastMessage!.messageType == 'video')
                    Row(
                      children: [
                        Icon(Icons.video_camera_back,
                            color: Color(0xFF797C7B), size: 16),
                        const SizedBox(width: 5),
                        Text(
                          "Video",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Color(0xFF797C7B),
                            fontSize: 12,
                            fontFamily: FontFamily.circular,
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.lastMessage != null
                      ? calculateTimeSinceLastMessage(
                          chat.lastMessage!.timestamp, ref)
                      : "",
                  style: TextStyle(
                    color: Color(0xFF797C7B),
                    fontSize: 12,
                    fontFamily: FontFamily.circular,
                  ),
                ),
                const SizedBox(height: 7),
                unseenMessagesCount.when(
                  data: (count) {
                    return count > 0
                        ? Container(
                            width: 21.81,
                            height: 21.81,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color(0xFFF04A4C),
                            ),
                            child: Center(
                              child: Text(
                                "$count",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: FontFamily.circular,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox();
                  },
                  error: (error, stackTrace) => SizedBox(),
                  loading: () => SizedBox(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getChatTitle(
      ChatDTO chat, String userId, UserRepositoryInterface userRepo) async {
    if (chat.type == 'group') {
      return chat.groupName ?? 'No group name';
    } else {
      final friendId =
          chat.participants!.firstWhere((id) => id != userId, orElse: () => '');

      if (friendId.isNotEmpty) {
        final friend = await userRepo.getUserDetails(friendId).first;
        return friend?.name ?? 'No friend name';
      }
      return '';
    }
  }
}
