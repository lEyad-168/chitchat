import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/widgets/app_bar_widget.dart';
import 'package:chitchat/core/widgets/home_content_background_widget.dart';
import 'package:chitchat/features/friends/presentation/widgets/friends_list_widget.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
                    title: "Friends",
                    rightButton: IconButton(
                      onPressed: () {
                        context.push('/add-friends');
                      },
                      icon: SvgPicture.asset(
                        Assets.icons.userAdd.path,
                        fit: BoxFit.scaleDown,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            HomeContentBackground(
              height: screenHeight - 190, //CHUTEI ESSE NUMERO
              child: FriendsListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
