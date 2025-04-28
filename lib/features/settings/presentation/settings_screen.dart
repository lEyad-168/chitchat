import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/widgets/app_bar_widget.dart';
import 'package:chitchat/core/widgets/home_content_background_widget.dart';
import 'package:chitchat/features/settings/presentation/widgets/settings_functions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
                    title: "Settings",
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            HomeContentBackground(
              height: screenHeight - 190, //CHUTEI ESSE NUMERO
              child: SettingsFunctions(),
            ),
          ],
        ),
      ),
    );
  }
}
