import 'package:chitchat/features/auth/data/dto/user_dto.dart';

abstract interface class UserRepositoryInterface {
  Stream<UserDTO?> getUserDetails(String userId);
  Stream<List<UserDTO>> searchUsers(String query);
  Future<void> updateUserOnlineStatus({required bool isOnline});
  Future<void> updateUserName({required String name});
  Future<void> updateUserStatusMessage({required String statusMessage});
  Future<void> updateUserProfilePic({required String photoURL});
  Future<void> removeUserProfilePic();
}
