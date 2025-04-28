import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/firebase_options.dart';
import 'package:chitchat/core/theme/app_theme.dart';
import 'package:chitchat/core/theme/theme_provider.dart';
import 'package:chitchat/core/routes/go_router_provider.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  String? _userId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeUser() async {
    final user = ref.watch(currentUserProvider).asData?.value;
    if (user != null) {
      _userId = user.uid;
      await _setUserOnline();
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_userId == null) return;

    if (state == AppLifecycleState.resumed) {
      _setUserOnline();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setUserOffline();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _setUserOnline() async {
    final userRepo = ref.watch(userRepositoryProvider);

    if (_userId != null) {
      await userRepo.updateUserOnlineStatus(isOnline: true);
    }
  }

  Future<void> _setUserOffline() async {
    final userRepo = ref.watch(userRepositoryProvider);

    if (_userId != null) {
      await userRepo.updateUserOnlineStatus(isOnline: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return FutureBuilder(
      future: _initializeUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !_isInitialized) {
          return MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: goRouter,
          );
        }
        return MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
        );
      },
    );
  }
}
