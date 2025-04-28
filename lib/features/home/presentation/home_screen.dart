import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/core/providers/bottom_nav_index_provider.dart';
import 'package:chitchat/features/chat/presentation/chats_list_screen.dart';
import 'package:chitchat/features/friends/presentation/friends_screen.dart';
import 'package:chitchat/features/settings/presentation/settings_screen.dart';
import 'package:chitchat/features/friends/presentation/providers/friends_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final friendsRequestsCount = ref.watch(friendsRequestCountProvider);
    final themeMode = ref.watch(themeProvider);

    final List<Widget> pages = [
      const ChatsListScreen(),
      const FriendsScreen(),
      const SettingsScreen(),
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: pages[currentIndex],
        bottomNavigationBar: SizedBox(
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode(ref, context)
                      ? Color(0xFF242E2E)
                      : Color(0xFFEEFAF8),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: themeMode == ThemeMode.dark
                  ? Colors.white
                  : Theme.of(context).primaryColor,
              unselectedItemColor: const Color(0xFF797C7B),
              selectedLabelStyle:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                      ),
              unselectedLabelStyle:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                        color: Color(0xFF797C7B),
                      ),
              showSelectedLabels: true,
              currentIndex: currentIndex,
              onTap: (index) =>
                  ref.read(bottomNavIndexProvider.notifier).state = index,
              items: [
                BottomNavigationBarItem(
                  icon: _buildSvgIcon(Assets.icons.message.path,
                      currentIndex == 0, context, themeMode),
                  label: "Chats",
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      _buildSvgIcon(Assets.icons.user.path, currentIndex == 1,
                          context, themeMode),
                      friendsRequestsCount.when(
                        data: (friendsRequests) => friendsRequests > 0
                            ? Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Color(0xFFF04A4C),
                                ),
                                child: Center(
                                  child: Text(
                                    "$friendsRequests",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: FontFamily.circular,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        error: (error, stackTrace) => SizedBox(),
                        loading: () => SizedBox(),
                      ),
                    ],
                  ),
                  label: "Friends",
                ),
                BottomNavigationBarItem(
                  icon: _buildSvgIcon(Assets.icons.settings.path,
                      currentIndex == 2, context, themeMode),
                  label: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSvgIcon(String assetPath, bool isSelected, BuildContext context,
      ThemeMode themeMode) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isSelected
            ? themeMode == ThemeMode.dark
                ? Colors.white
                : Theme.of(context).primaryColor
            : Color(0xFF797C7B),
        BlendMode.srcIn,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: SvgPicture.asset(assetPath, width: 26, height: 26),
      ),
    );
  }
}
