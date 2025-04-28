import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/friends/data/repositories/friends_repository.dart';

final friendsListProvider = StreamProvider<List<UserDTO?>>((ref) {
  final friendsRepo = ref.watch(friendsRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return friendsRepo.getFriends().asyncMap((friendUids) async {
    if (friendUids == null || friendUids.isEmpty) {
      return [];
    }

    final friendsStreams = friendUids.map((uid) async {
      final user = await userRepo.getUserDetails(uid).first;
      if (user != null) {
        return user.copyWith(uid: uid);
      }
      return null;
    }).toList();

    final friendsList = await Future.wait(friendsStreams);
    return friendsList.whereType<UserDTO>().toList();
  });
});

final friendRequestsProvider = StreamProvider<List<UserDTO?>>((ref) {
  final friendsRepo = ref.watch(friendsRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return friendsRepo.getFriendsRequests().asyncMap((requestUids) async {
    if (requestUids == null || requestUids.isEmpty) {
      return [];
    }

    final requestStreams = requestUids.map((uid) async {
      final user = await userRepo.getUserDetails(uid).first;
      if (user != null) {
        return user.copyWith(uid: uid);
      }
      return null;
    }).toList();

    final friendsList = await Future.wait(requestStreams);
    return friendsList.whereType<UserDTO>().toList();
  });
});

final friendsRequestCountProvider = StreamProvider<int>((ref) {
  final friendsRepo = ref.watch(friendsRepositoryProvider);
  return friendsRepo
      .getFriendsRequests()
      .map((requests) => requests?.length ?? 0);
});
