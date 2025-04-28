import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/widgets/app_bar_widget.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/core/widgets/home_content_background_widget.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/users/presentation/widgets/user_details.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_profile_pic.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserDetailsScreen({required this.userId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;

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
                        context.pop();
                      },
                      icon: SvgPicture.asset(
                        Assets.icons.backButton.path,
                        fit: BoxFit.scaleDown,
                        height: 18.33,
                        width: 18.33,
                      ),
                    ),
                    title: "",
                  ),
                  Column(
                    children: [
                      StreamBuilder(
                        stream: userRepo.getUserDetails(widget.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final user = snapshot.data!;

                          final chatPhoto = user.photoURL;

                          final hasValidPhoto =
                              chatPhoto != null && chatPhoto.isNotEmpty;

                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (hasValidPhoto) {
                                    context
                                        .push('/view-profile-pic/${user.uid}');
                                  } else if (!hasValidPhoto &&
                                      currentUser!.uid == widget.userId) {
                                    context
                                        .push('/view-profile-pic/${user.uid}');
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: 'This user has no profile picture',
                                    );
                                  }
                                },
                                child: Hero(
                                  tag: 'profilePic',
                                  child: ChatProfilePic(
                                    avatarRadius: 41,
                                    chatPhotoURL:
                                        hasValidPhoto ? chatPhoto : null,
                                    isOnline: user.isOnline!,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                user.name ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.isOnline!
                                    ? 'Online'
                                    : lastSeenDateOrTime(user.lastSeen!, ref),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 12,
                                      color: Color(0xFFA5E7DE),
                                    ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            HomeContentBackground(
              height: screenHeight -
                  (currentUser!.uid != widget.userId ? 250 : 250),
              child: StreamBuilder(
                stream: userRepo.getUserDetails(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final user = snapshot.data!;
                  return UserDetails(user: user);
                },
              ),
            ),
          ],
        ),
      ),
    );
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
