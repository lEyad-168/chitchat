import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/auth/data/repositories/auth_repository.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/chat/presentation/widgets/chat_text_field.dart';
import 'package:chitchat/features/settings/presentation/widgets/setting_button.dart';

class UserDetails extends ConsumerStatefulWidget {
  final UserDTO user;
  const UserDetails({required this.user, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserDetailsState();
}

class _UserDetailsState extends ConsumerState<UserDetails> {
  @override
  Widget build(BuildContext context) {
    final authRepo = ref.watch(authRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 41 - 15), // -15 for the top padding
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: currentUser!.uid == widget.user.uid
                  ? () {
                      _buildBottomModalSheet("name", widget.user.name ?? "");
                    }
                  : null,
              child: _buildUserDetail(
                "Display name",
                widget.user.name,
                isEditable: currentUser.uid == widget.user.uid,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: currentUser.uid == widget.user.uid
                  ? () {
                      _buildBottomModalSheet(
                          "status", widget.user.statusMessage ?? "");
                    }
                  : null,
              child: _buildUserDetail(
                "Status message",
                widget.user.statusMessage,
                isEditable: currentUser.uid == widget.user.uid,
              ),
            ),
          ),
          _buildUserDetail(
            "Email address",
            widget.user.email,
          ),
          _buildUserDetail(
            "Joined at",
            DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(widget.user.createdAt!)),
          ),
          const SizedBox(height: 32),
          currentUser.uid == widget.user.uid
              ? Material(
                  color: Colors.redAccent.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: SettingButton(
                    title: "Sign out",
                    subtitle: "Sign out of your account",
                    subtitleStyle:
                        Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                    onTap: () async {
                      try {
                        await authRepo.logout();
                        context.go("/onboarding");
                      } on Exception catch (e) {
                        Fluttertoast.showToast(msg: "Error: $e");
                      }
                    },
                  ),
                )
              : Container(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserDetail(String title, String? value,
      {bool isEditable = false}) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                value ?? "",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                    ),
              ),
              const SizedBox(
                width: 10,
              ),
              if (currentUser!.uid == widget.user.uid && isEditable)
                const Icon(
                  Icons.edit,
                  size: 16,
                )
            ],
          )
        ],
      ),
    );
  }

  void _buildBottomModalSheet(String infoToChange, String currentValue) {
    final userRepo = ref.watch(userRepositoryProvider);

    final controller = TextEditingController();
    controller.text = currentValue;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8.0),
                child: Text(
                  infoToChange == "name" ? "Edit name" : "Edit status message",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 18,
                      ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8.0),
                child: ChatTextField(
                  hintText: infoToChange == "name"
                      ? "Type your name"
                      : "Type your status message",
                  controller: controller,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FilledButton(
                        onPressed: () {
                          try {
                            if (infoToChange == "name") {
                              userRepo.updateUserName(name: controller.text);
                            } else {
                              userRepo.updateUserStatusMessage(
                                  statusMessage: controller.text);
                            }
                            context.pop();
                            Fluttertoast.showToast(msg: "Changes saved");
                          } on Exception catch (e) {
                            Fluttertoast.showToast(msg: "Error: $e");
                          }
                        },
                        child: Text("Save changes"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text("Cancel"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
