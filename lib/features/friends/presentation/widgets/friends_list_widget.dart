import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/friends/data/repositories/friends_repository.dart';
import 'package:chitchat/features/friends/domain/friends_repository_interface.dart';
import 'package:chitchat/features/friends/presentation/providers/friends_providers.dart';
import 'package:chitchat/features/chat/domain/repositories/chat_repository_interface.dart';

class FriendsListWidget extends ConsumerWidget {
  const FriendsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsList = ref.watch(friendsListProvider);
    final friendRequests = ref.watch(friendRequestsProvider);
    final friendRequestCount = ref.watch(friendsRequestCountProvider);
    final chatRepository = ref.watch(chatRepositoryProvider);
    final friendsRepository = ref.watch(friendsRepositoryProvider);

    final themeMode = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: SingleChildScrollView(
        child: Column(
          children: [
            friendRequestsList(friendRequests, friendsRepository, context, ref),
            if (friendRequestCount.value! > 0)
              Column(children: [
                const SizedBox(height: 10),
                Divider(
                    height: 1,
                    color: themeMode == ThemeMode.dark
                        ? Color(0xFF2D2F2E)
                        : Color(0xFFF5F6F6)),
                const SizedBox(height: 10),
              ]),
            friendList(
                friendsList, chatRepository, friendsRepository, context, ref),
          ],
        ),
      ),
    );
  }

  Widget friendList(
      AsyncValue<List<UserDTO?>> friendsList,
      ChatRepositoryInterface chatRepository,
      FriendsRepositoryInterface friendsRepository,
      BuildContext context,
      WidgetRef ref) {
    return friendsList.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Center(
            child: Text(
              "No friends yet",
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
                "Friends",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                bool isTheFirstFriendWithThisLetter = index == 0 ||
                    friends[index - 1]!.name![0] != friends[index]!.name![0];

                return Column(
                  children: [
                    if (isTheFirstFriendWithThisLetter)
                      Padding(
                        padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: index == 0 ? 0 : 30,
                            bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            friends[index]!.name![0],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ),
                    Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.15,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(Assets.icons.trash.path,
                                width: 22),
                            padding: const EdgeInsets.all(7),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    title: Text(
                                      "Remove friend",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 24,
                                          ),
                                    ),
                                    content: Text(
                                      "Are you sure you want to remove this friend?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 12,
                                          ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          "Cancel",
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FilledButton(
                                        child: Text(
                                          "Remove",
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          friendsRepository.removeFriend(
                                            friends[index]!.uid!,
                                          );
                                          Fluttertoast.showToast(
                                            msg: "Friend removed",
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Color(0xFFEA3736)),
                            ),
                          ),
                        ],
                      ),
                      child: friendButton(
                          chatRepository, friends, index, context, ref),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
      error: (error, stackTrace) => Center(
          child: Text(
        error.toString(),
        style: TextStyle(color: Colors.white),
      )),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }

  Widget friendRequestsList(
      AsyncValue<List<UserDTO?>> friendRequests,
      FriendsRepositoryInterface friendsRepository,
      BuildContext context,
      WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return friendRequests.when(
      data: (friendRequests) {
        if (friendRequests.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'You have ${friendRequests.length} ${friendRequests.length > 1 ? "Friend requests" : "Friend request"}.',
                  // 'You have ${friendRequests.length} friend request${friendRequests.length > 1 ? 's' : ''}:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  final chatPhoto = friendRequests[index]!.photoURL;
                  final hasValidPhoto =
                      chatPhoto != null && chatPhoto.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ChatProfilePic(
                                  chatPhotoURL: hasValidPhoto
                                      ? friendRequests[index]!.photoURL
                                      : null,
                                  isOnline: false,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friendRequests[index]!.name ?? 'No name',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 18,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3E9D9D),
                                      ),
                                      onPressed: () {
                                        friendsRepository.acceptFriendRequest(
                                            friendRequests[index]!.uid!);

                                        Fluttertoast.showToast(
                                          msg: "Friend request accepted",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor:
                                              const Color(0xFF3E9D9D),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      },
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: FontFamily.circular,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: TextButton(
                                      onPressed: () {
                                        friendsRepository.rejectFriendRequest(
                                            friendRequests[index]!.uid!);

                                        Fluttertoast.showToast(
                                          msg: "Friend request declined",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor:
                                              const Color(0xFF3E9D9D),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .cardColor
                                              .withAlpha(50),
                                        ),
                                      ),
                                      child: Text(
                                        "Decline",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 12,
                                              color: themeMode ==
                                                          ThemeMode.dark ||
                                                      (themeMode ==
                                                              ThemeMode
                                                                  .system &&
                                                          MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.dark)
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }
        return Container();
      },
      error: (error, stackTrace) => Center(
          child: Text(
        error.toString(),
        style: TextStyle(color: Colors.white),
      )),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }

  Widget friendButton(ChatRepositoryInterface chatRepository,
      List<UserDTO?> friends, int index, BuildContext context, WidgetRef ref) {
    final friendPhoto = friends[index]!.photoURL;
    final hasValidPhoto = friendPhoto != null && friendPhoto.isNotEmpty;
    final userProvider = ref.watch(userRepositoryProvider);
    final friendId = friends[index]!.uid!;
    final friendDetails = userProvider.getUserDetails(friendId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final chatId = await chatRepository
              .getPrivateChatIdByFriendId(friends[index]!.uid!);

          if (chatId != null) {
            context.push('/chat/$chatId');
          } else {
            await chatRepository.createPrivateChat(friends[index]!.uid!);
            context.push('/chat/${friends[index]!.uid}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder(
                stream: friendDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final friend = snapshot.data;
                  return ChatProfilePic(
                    chatPhotoURL: hasValidPhoto ? friendPhoto : null,
                    isOnline: friend!.isOnline ?? false,
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friends[index]!.name ?? 'No name',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  if (friends[index]!.statusMessage != null &&
                      friends[index]!.statusMessage!.isNotEmpty)
                    Text(
                      friends[index]!.statusMessage!,
                      style: TextStyle(
                        color: Color(0xFF797C7B),
                        fontSize: 12,
                        fontFamily: FontFamily.circular,
                      ),
                    )
                  else
                    SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
