import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/home/presentation/home_screen.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/chat/presentation/chat_screen.dart';
import 'package:chitchat/features/auth/presentation/login_screen.dart';
import 'package:chitchat/features/auth/presentation/signup_screen.dart';
import 'package:chitchat/features/search/presentation/search_screen.dart';
import 'package:chitchat/features/auth/presentation/onboarding_screen.dart';
import 'package:chitchat/features/chat/presentation/chats_list_screen.dart';
import 'package:chitchat/features/chat/presentation/view_media_screen.dart';
import 'package:chitchat/features/chat/presentation/create_group_screen.dart';
import 'package:chitchat/features/settings/presentation/settings_screen.dart';
import 'package:chitchat/features/friends/presentation/add_friend_screen.dart';
import 'package:chitchat/features/users/presentation/user_details_screen.dart';
import 'package:chitchat/features/settings/presentation/app_settings_screen.dart';
import 'package:chitchat/features/settings/presentation/chat_settings_screen.dart';
import 'package:chitchat/features/users/presentation/view_profile_pic_screen.dart';
import 'package:chitchat/features/chat/presentation/send_media_confirmation_screen.dart';
import 'package:chitchat/features/chat/presentation/select_friends_to_create_group_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  return GoRouter(
    initialLocation: user == null ? '/onboarding' : '/home',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chats-list',
        name: 'chats-list',
        builder: (context, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: '/add-friends',
        name: 'add-friends',
        builder: (context, state) => const AddFriendScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'chat-settings',
            name: 'chat-settings',
            builder: (context, state) => const ChatSettingsScreen(),
          ),
          GoRoute(
            path: 'app-settings',
            name: 'app-settings',
            builder: (context, state) => const AppSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        builder: (context, state) =>
            ChatScreen(chatId: state.pathParameters['chatId']!),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/create-group',
        name: 'create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/select-friends-to-create-group',
        name: 'select-friends-to-create-group',
        builder: (context, state) => const SelectFriendsToCreateGroupScreen(),
      ),
      GoRoute(
        path: '/user-details/:userId',
        name: 'user-details',
        builder: (context, state) =>
            UserDetailsScreen(userId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: '/send-media-confirmation',
        name: 'send-media-confirmation',
        builder: (context, state) {
          final chatId = state.uri.queryParameters['chatId'];
          final mediaPath = state.uri.queryParameters['mediaPath'];

          return SendMediaConfirmationScreen(
            chatId: chatId!,
            mediaFilePath: mediaPath!,
          );
        },
      ),
      GoRoute(
        path: '/view-media',
        name: 'view-media',
        builder: (context, state) {
          final mediaUrl = state.uri.queryParameters['mediaUrl'];

          return ViewMediaScreen(
            mediaUrl: mediaUrl!,
          );
        },
      ),
      GoRoute(
        path: '/view-profile-pic/:userId',
        name: 'view-profile-pic',
        builder: (context, state) {
          return ViewProfilePicScreen(
            userId: state.pathParameters['userId']!,
          );
        },
      ),
    ],
  );
});
