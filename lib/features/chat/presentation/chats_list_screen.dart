import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/widgets/app_bar_widget.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/core/widgets/home_content_background_widget.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_list.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatsListScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final userRepo = ref.watch(userRepositoryProvider);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
              ),
              child: Column(
                children: [
                  SizedBox(height: 17),
                  AppBarWidget(
                    leftButton: IconButton(
                      onPressed: () {
                        context.push('/search');
                      },
                      icon: SvgPicture.asset(
                        Assets.icons.search.path,
                        fit: BoxFit.scaleDown,
                        height: 18.33,
                        width: 18.33,
                      ),
                    ),
                    title: "Home",
                    rightButton: GestureDetector(
                      onTap: () =>
                          context.push('/user-details/${currentUser.uid}'),
                      child: StreamBuilder(
                        stream: userRepo.getUserDetails(currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final user = snapshot.data!;
                          return Hero(
                            tag: 'profilePic',
                            child: ChatProfilePic(
                              avatarRadius: 22,
                              chatPhotoURL: user.photoURL,
                              isOnline: false,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
            HomeContentBackground(
              height: screenHeight - 190,
              child: ChatList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightBlue,
          onPressed: () {
            context.push('/create-group');
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
