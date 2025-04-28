import 'package:chitchat/features/auth/data/dto/user_dto.dart';

abstract interface class FriendsRepositoryInterface {
  Future<void> sendFriendRequest(String friendId);
  Future<void> removeFriend(String friendId);
  Future<void> acceptFriendRequest(String friendId);
  Future<void> rejectFriendRequest(String friendId);
  Stream<List<String>?> getFriends();
  Stream<List<UserDTO>> searchFriends(String query);
  Stream<List<String>?> getFriendsRequests();
  Future<bool> isFriend(String friendId);
}
