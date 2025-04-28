import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';
import 'package:chitchat/features/friends/data/repositories/friends_repository.dart';
import 'package:chitchat/features/chat/presentation/providers/friends_list_to_create_group_provider.dart';

class SelectFriendsToCreateGroupScreen extends ConsumerStatefulWidget {
  const SelectFriendsToCreateGroupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectFriendsToCreateGroupScreenState();
}

class _SelectFriendsToCreateGroupScreenState
    extends ConsumerState<SelectFriendsToCreateGroupScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final friendsRepo = ref.watch(friendsRepositoryProvider);
    final friendsListToCreateGroup =
        ref.watch(friendsListToCreateGroupProvider);
    final query = _searchController.text.toLowerCase();
    final friendsStream = friendsRepo.searchFriends(query);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (friendsListToCreateGroup.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${friendsListToCreateGroup.length > 1 ? "Friends selected" : "Friend selected"}: ${friendsListToCreateGroup.length}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 14,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: friendsListToCreateGroup.map(
                      (friend) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: () => _removeUserFromGroup(ref, friend.uid!),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ChatProfilePic(
                                  chatPhotoURL: friend.photoURL,
                                  isOnline: false,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: themeMode == ThemeMode.light
                                          ? Colors.white
                                          : Color(0xFF121414),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                    color: Color(0xFFEA3736),
                                  ),
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            // const SizedBox(height: 10),
            SingleChildScrollView(
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            child: Text(
                              "Select friends to create group",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
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
                                color: _isFriendSelected(ref, friend.uid!)
                                    ? Color.fromARGB(118, 36, 120, 109)
                                    : Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    _addUserToGroup(ref, friend);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            ChatProfilePic(
                                              chatPhotoURL: friend.photoURL,
                                              isOnline:
                                                  friend.isOnline ?? false,
                                            ),
                                            _isFriendSelected(ref, friend.uid!)
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF24786D),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      color: Color(0xFF24786D),
                                                    ),
                                                    child: Icon(
                                                      Icons.done,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
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
                                                friend
                                                    .statusMessage!.isNotEmpty)
                                              Text(
                                                friends[index].statusMessage!,
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
                                ),
                              );
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pop(),
          backgroundColor: Color(0xFF24786D),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _addUserToGroup(WidgetRef ref, UserDTO user) {
    ref.read(friendsListToCreateGroupProvider.notifier).update((state) {
      if (state.any((u) => u.uid == user.uid)) {
        return state; // 🔥 Evita duplicatas
      }
      return [...state, user];
    });
  }

  void _removeUserFromGroup(WidgetRef ref, String uid) {
    ref.read(friendsListToCreateGroupProvider.notifier).update((state) {
      return state.where((user) => user.uid != uid).toList();
    });
  }

  bool _isFriendSelected(WidgetRef ref, String uid) {
    return ref
        .read(friendsListToCreateGroupProvider.notifier)
        .state
        .any((user) => user.uid == uid);
  }
}
