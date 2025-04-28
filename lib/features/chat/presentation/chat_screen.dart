import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/features/chat/data/dto/chat_dto.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/users/domain/user_repository_interface.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/chat/domain/repositories/chat_repository_interface.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({required this.chatId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = ref.watch(chatRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: chitchatBar(chatProvider, userRepo, currentUser, context, ref),
        body: Column(
          children: [
            StreamBuilder(
              stream: chatProvider.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        "No message yet",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 24,
                            ),
                      ),
                    ),
                  );
                }

                // scroll to the end when a new message appears
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return messagesList(messages, currentUser, userRepo, ref);
              },
            ),
            ChatInputField(chatId: widget.chatId),
          ],
        ),
      ),
    );
  }

  AppBar chitchatBar(
      ChatRepositoryInterface chatProvider,
      UserRepositoryInterface userRepo,
      AsyncValue<User?> currentUser,
      BuildContext context,
      WidgetRef ref) {
    return AppBar(
        toolbarHeight: 124,
        backgroundColor: Colors.transparent,
        leading: AuthBackButton(),
        title: StreamBuilder(
          stream: chatProvider.getChatDetails(widget.chatId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final chat = snapshot.data!;

            if (chat.type == 'group') {
              return Row(
                children: [
                  FutureBuilder(
                    future: chatProvider.getChatPhotoURL(
                      chat,
                      userRepo,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                            color: Colors.white);
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final chatPhoto = snapshot.data;
                      final hasValidPhoto =
                          chatPhoto != null && chatPhoto.isNotEmpty;

                      return ChatProfilePic(
                        chatPhotoURL: hasValidPhoto ? chatPhoto : '',
                        isOnline: false,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        currentUser.when(
                          data: (user) {
                            return FutureBuilder(
                              future: _getChatTitle(chat, user!.uid, userRepo),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'No title',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 20,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                );
                              },
                            );
                          },
                          error: (error, stackTrace) => Text('Error: $error'),
                          loading: () => const CircularProgressIndicator(),
                        ),
                        const SizedBox(height: 6),
                        StreamBuilder(
                          stream: chatProvider.getNumberOfOnlineMembers(
                            widget.chatId,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            final onlineMembers = snapshot.data ?? 0;
                            return Text(
                              '${chat.participants!.length} Members ${onlineMembers > 0 ? ', $onlineMembers Online' : ''}',
                              style: TextStyle(
                                color: Color(0xFF797C7B),
                                fontSize: 12,
                                fontFamily: FontFamily.circular,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
              // if it's a private chat
            } else {
              final friendId = chat.participants != null
                  ? chat.participants!.firstWhere(
                      (id) => id != currentUser.value?.uid,
                      orElse: () => '',
                    )
                  : '';

              final friendDetails = userRepo.getUserDetails(friendId);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/user-details/$friendId'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        FutureBuilder(
                          future: chatProvider.getChatPhotoURL(
                            chat,
                            userRepo,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                  color: Colors.white);
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            final chatPhoto = snapshot.data;
                            final hasValidPhoto =
                                chatPhoto != null && chatPhoto.isNotEmpty;

                            final friendId = (chat.type == 'private' &&
                                    chat.participants != null)
                                ? chat.participants!.firstWhere(
                                    (id) => id != currentUser.value?.uid,
                                    orElse: () => '',
                                  )
                                : '';

                            final friendDetails =
                                userRepo.getUserDetails(friendId);

                            return StreamBuilder(
                              stream: friendDetails,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                      color: Colors.white);
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                final friend = snapshot.data!;

                                return ChatProfilePic(
                                  chatPhotoURL:
                                      hasValidPhoto ? chatPhoto : null,
                                  isOnline: friend.isOnline!,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              currentUser.when(
                                data: (user) {
                                  return FutureBuilder(
                                    future: _getChatTitle(
                                        chat, user!.uid, userRepo),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? 'No title',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 20,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      );
                                    },
                                  );
                                },
                                error: (error, stackTrace) =>
                                    Text('Error: $error'),
                                loading: () =>
                                    const CircularProgressIndicator(),
                              ),
                              const SizedBox(height: 6),
                              StreamBuilder(
                                stream: friendDetails,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                      'Checking...',
                                      style: TextStyle(
                                        color: Color(0xFF797C7B),
                                        fontSize: 12,
                                        fontFamily: FontFamily.circular,
                                      ),
                                    );
                                  }
                                  final friend = snapshot.data;
                                  return Text(
                                    friend!.isOnline ?? false
                                        ? 'online'
                                        : lastSeenDateOrTime(
                                            friend.lastSeen ?? '', ref),
                                    style: TextStyle(
                                      color: Color(0xFF797C7B),
                                      fontSize: 12,
                                      fontFamily: FontFamily.circular,
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ));
  }

  Widget messagesList(List<MessageDTO> messages, AsyncValue<User?> currentUser,
      UserRepositoryInterface userRepo, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isMe = message.senderId == currentUser.value?.uid;

          // Check if the next or previous message is from the same sender
          final bool isNextFromSameSender = index < messages.length - 1 &&
              messages[index + 1].senderId == message.senderId;
          final bool isPreviousFromSameSender =
              index > 0 && messages[index - 1].senderId == message.senderId;

          // Define a smaller padding if the next message is from the same user
          final double bottomPadding = isNextFromSameSender ? 5 : 30;

          // Check if the current message is the first message of the day
          final bool isFirstMessageOfTheDay = index == 0 ||
              DateTime.parse(messages[index - 1].timestamp!).day !=
                  DateTime.parse(messages[index].timestamp!).day;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isFirstMessageOfTheDay)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeMode == ThemeMode.light
                          ? Color(0xFFF2F7FB)
                          : Color(0xFF1D2525),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Text(
                      messageDate(messages[index].timestamp!, ref),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 12,
                            color: themeMode == ThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                    ),
                  ),
                ),
              chatBubble(
                bottomPadding,
                isMe,
                isNextFromSameSender,
                isPreviousFromSameSender,
                message,
                index == messages.length - 1,
                userRepo,
                ref,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget chatBubble(
      double bottomPadding,
      bool isMe,
      bool isNextFromSameSender,
      bool isPreviousFromSameSender,
      MessageDTO message,
      bool islastMessage,
      UserRepositoryInterface userProvider,
      WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 24, right: 24),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisAlignment: key to align like the design
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isPreviousFromSameSender && !isMe)
                  StreamBuilder(
                    stream: userProvider.getUserDetails(message.senderId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final user = snapshot.data;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ChatProfilePic(
                            chatPhotoURL: user!.photoURL,
                            isOnline: user.isOnline ?? false,
                          ),
                        ],
                      );
                    },
                  )
                else
                  // width of the profile pic, got from flutter inspector
                  const SizedBox(width: 52),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: !isPreviousFromSameSender
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (!isPreviousFromSameSender && !isMe)
                      StreamBuilder(
                        stream: userProvider.getUserDetails(message.senderId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final user = snapshot.data;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  user!.name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 14,
                                      ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    if (!isPreviousFromSameSender && !isMe)
                      const SizedBox(height: 12),
                    if (message.messageType == 'text')
                      textMessage(
                        isMe,
                        themeMode,
                        isNextFromSameSender,
                        isPreviousFromSameSender,
                        message,
                      ),
                    if (message.messageType == 'image')
                      mediaMessage(
                        isMe,
                        themeMode,
                        isNextFromSameSender,
                        isPreviousFromSameSender,
                        message,
                      ),
                    if (message.messageType == 'video')
                      mediaMessage(
                        isMe,
                        themeMode,
                        isNextFromSameSender,
                        isPreviousFromSameSender,
                        message,
                        isVideo: true,
                      ),
                    if (islastMessage)
                      Row(
                        children: [
                          ...message.seenBy!
                              .where((userId) => userId != currentUser!.uid)
                              .take(2)
                              .map((userId) {
                            return StreamBuilder(
                              stream: userProvider.getUserDetails(userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return Transform.translate(
                                  offset: Offset(0.0, 0.0),
                                  child: Icon(Icons.done_all_rounded, size: 16,),
                                );
                              },
                            );
                          }),
                          if (message.seenBy!.length - 1 > 2)
                            Transform.translate(
                              offset: Offset(-10, 0.0),
                              child: CircleAvatar(
                                backgroundColor: isDarkMode(ref, context)
                                    ? Color(0xFF212727)
                                    : Color(0xFFF2F7FB),
                                radius: 10,
                                child: Text(
                                  '+${message.seenBy!.length - 2}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 10,
                                        color: isDarkMode(ref, context)
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            if (!isNextFromSameSender) // Display the time only on the last message of the group
              Padding(
                padding: const EdgeInsets.only(left: 74, top: 5),
                child: Text(
                  DateFormat.jm()
                      .format(DateTime.parse(message.timestamp ?? '')),
                  style: const TextStyle(
                    color: Color(0xFF797C7B),
                    fontSize: 10,
                    fontFamily: FontFamily.circular,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget textMessage(bool isMe, ThemeMode themeMode, bool isNextFromSameSender,
      bool isPreviousFromSameSender, MessageDTO message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.lightBlue
            : themeMode == ThemeMode.light
                ? Color(0xFFF2F7FB)
                : Color(0xFF1D2525),
        borderRadius: BorderRadius.only(
          // If it's the FIRST message in the sequence, the bottom corner is flat
          bottomRight: isMe
              ? (isNextFromSameSender ? Radius.zero : Radius.circular(50))
              : Radius.circular(50),
          bottomLeft: isMe
              ? Radius.circular(50)
              : (isNextFromSameSender ? Radius.zero : Radius.circular(50)),

          // If it's the LAST message in the sequence, the top corner is flat
          topRight: isMe
              ? (isPreviousFromSameSender ? Radius.zero : Radius.circular(50))
              : Radius.circular(50),
          topLeft: isMe
              ? Radius.circular(50)
              : (isPreviousFromSameSender ? Radius.zero : Radius.circular(50)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        message.text ?? '',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12,
              color: themeMode == ThemeMode.light
                  ? isMe
                      ? Colors.white
                      : Colors.black
                  : Colors.white,
            ),
      ),
    );
  }

  Widget mediaMessage(bool isMe, ThemeMode themeMode, bool isNextFromSameSender,
      bool isPreviousFromSameSender, MessageDTO message,
      {bool isVideo = false}) {
    return GestureDetector(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.lightBlue
              : themeMode == ThemeMode.light
                  ? Color(0xFFF2F7FB)
                  : Color(0xFF1D2525),
          borderRadius: BorderRadius.only(
            // If it's the FIRST message in the sequence, the bottom corner is flat
            bottomRight: isMe
                ? (isNextFromSameSender ? Radius.zero : Radius.circular(10))
                : Radius.circular(10),
            bottomLeft: isMe
                ? Radius.circular(10)
                : (isNextFromSameSender ? Radius.zero : Radius.circular(10)),

            // If it's the LAST message in the sequence, the top corner is flat
            topRight: isMe
                ? (isPreviousFromSameSender ? Radius.zero : Radius.circular(10))
                : Radius.circular(10),
            topLeft: isMe
                ? Radius.circular(10)
                : (isPreviousFromSameSender
                    ? Radius.zero
                    : Radius.circular(10)),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            isVideo
                ?
                // video thumbnail here
                FutureBuilder(
                    future: VideoThumbnail.thumbnailFile(
                      video: message.text ?? '',
                      imageFormat: ImageFormat.JPEG,
                      quality: 75,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final data = snapshot.data;
                      return kIsWeb
                          ? Image.network(data!.path)
                          : Image.file(File(data!.path));
                    },
                  )
                : Image.network(
                    message.text ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error loading image',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            if (isVideo)
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey.withAlpha(150),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
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

  String messageDate(String timestamp, WidgetRef ref) {
    final messageDate = DateTime.parse(timestamp);

    if (messageDate.day == DateTime.now().day) {
      return "Today";
    } else if (messageDate.day ==
        DateTime.now().subtract(const Duration(days: 1)).day) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(
        DateTime.parse(timestamp),
      );
    }
  }

  String lastSeenDateOrTime(String timestamp, WidgetRef ref) {
    final lastSeenDate = DateTime.parse(timestamp);

    if (lastSeenDate.day == DateTime.now().day) {
      return 'Last seen at ${DateFormat.jm().format(DateTime.parse(timestamp))}';
    } else {
      return 'Last seen in ${DateFormat("dd/MM/yyyy").format(DateTime.parse(timestamp))}';
    }
  }
}
