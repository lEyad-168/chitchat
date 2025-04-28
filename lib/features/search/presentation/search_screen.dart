import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/friends/data/repositories/friends_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final friendsRepo = ref.watch(friendsRepositoryProvider);
    final chatRepo = ref.watch(chatRepositoryProvider);
    final query = _searchController.text.toLowerCase();
    final friendsStream = friendsRepo.searchFriends(query);
    final chatsStream = chatRepo.searchChats(query);
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leadingWidth: 44,
          leading: IconButton(
            icon: SvgPicture.asset(
              Assets.icons.backButton.path,
              colorFilter: ColorFilter.mode(
                themeMode == ThemeMode.light ? Colors.black : Colors.white,
                BlendMode.srcIn,
              ),
              fit: BoxFit.scaleDown,
              width: 18,
              height: 18,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          title: Container(
            height: 44,
            decoration: BoxDecoration(
              border: themeMode == ThemeMode.light
                  ? null
                  : Border(
                      top: BorderSide(
                        color: Color(0xFF192222),
                        width: 1,
                      ),
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    color: themeMode == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                  ),
              cursorColor:
                  themeMode == ThemeMode.light ? Colors.black : Colors.white,
              //autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: SvgPicture.asset(
                    Assets.icons.search.path,
                    colorFilter: ColorFilter.mode(
                      themeMode == ThemeMode.light
                          ? Colors.black
                          : Colors.white,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                    width: 20,
                    height: 20,
                  ),
                ),
                filled: true,
                fillColor: themeMode == ThemeMode.light
                    ? Color(0xFFF3F6F6)
                    : Color(0xFF192222),
                hintText: "Type to search",
                hintStyle: TextStyle(
                  color: Color(0xFF797C7B),
                  fontSize: 12,
                  fontFamily: FontFamily.circular,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              StreamBuilder(
                stream: friendsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) return const SizedBox();
                  final friends = snapshot.data!;
                  if (friends.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Text(
                          "Friends",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 16,
                                  ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final chatId = await chatRepo
                                    .getPrivateChatIdByFriendId(friend.uid!);
                                if (chatId != null) {
                                  context.push('/chat/$chatId');
                                } else {
                                  await chatRepo.createPrivateChat(friend.uid!);
                                  context.push('/chat/${friend.uid}');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ChatProfilePic(
                                      chatPhotoURL: friend.photoURL,
                                      isOnline: friend.isOnline ?? false,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friend.name ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontSize: 16,
                                              ),
                                        ),
                                        if (friend.statusMessage != null &&
                                            friend.statusMessage!.isNotEmpty)
                                          Text(
                                            friends[index].statusMessage!,
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
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: chatsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chats = snapshot.data!;
                  if (chats.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Text(
                          "Group Chats",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 16,
                                  ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.push('/chat/${chat.id}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ChatProfilePic(
                                      chatPhotoURL: chat.groupPhotoURL,
                                      isOnline: false,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chat.groupName ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontSize: 16,
                                              ),
                                        ),
                                        if (chat.lastMessage!.text != null &&
                                            chat.lastMessage!.text!.isNotEmpty)
                                          Text(
                                            chat.lastMessage!.text!,
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
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
