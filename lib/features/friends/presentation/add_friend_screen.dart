import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/friends/data/repositories/friends_repository.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // final chatRepo = ref.watch(chatRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final friendRepo = ref.watch(friendsRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final query = _searchController.text.toLowerCase();
    final searchResults = userRepo.searchUsers(query);
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
                hintText: 'Type to search friends to add',
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
                stream: searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) return const SizedBox();
                  final users = snapshot.data!;
                  if (users.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Text(
                          'Add Friends',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 16,
                                  ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          // check if the user is the current user itself
                          if (user.uid == currentUser?.uid) {
                            return const SizedBox();
                          }

                          return FutureBuilder(
                              future: friendRepo.isFriend(user.uid!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox();
                                }

                                // check if the user is already a friend
                                if (snapshot.data == true) {
                                  return const SizedBox();
                                }

                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ChatProfilePic(
                                            chatPhotoURL: user.photoURL,
                                            isOnline: user.isOnline ?? false,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 16,
                                                    ),
                                              ),
                                              if (user.statusMessage != null &&
                                                  user.statusMessage!
                                                      .isNotEmpty)
                                                Text(
                                                  users[index].statusMessage!,
                                                  style: TextStyle(
                                                    color: Color(0xFF797C7B),
                                                    fontSize: 12,
                                                    fontFamily:
                                                        FontFamily.circular,
                                                  ),
                                                )
                                              else
                                                SizedBox(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: IconButton(
                                        icon: SvgPicture.asset(
                                            Assets.icons.userAdd.path,
                                            width: 22),
                                        padding: const EdgeInsets.all(7),
                                        onPressed: () {
                                          friendRepo
                                              .sendFriendRequest(user.uid!);
                                          Fluttertoast.showToast(
                                            msg: "Friend request sent",
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Colors.lightBlue),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                      const SizedBox(height: 16),
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
