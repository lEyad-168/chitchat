import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/core/providers/firebase_firestore_provider.dart';
import 'package:chitchat/features/users/domain/user_repository_interface.dart';

final userRepositoryProvider = Provider<UserRepositoryInterface>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final currentUser = ref.watch(currentUserProvider).asData?.value;
  return UserRepository(firestore, currentUser!.uid);
});

class UserRepository implements UserRepositoryInterface {
  final FirebaseFirestore _firestore;
  final String _userId;

  UserRepository(this._firestore, this._userId);

  @override
  Stream<UserDTO?> getUserDetails(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return UserDTO.fromJson(doc.data()!).copyWith(uid: doc.id);
    });
  }

  @override
  Stream<List<UserDTO>> searchUsers(String query) {
    return _firestore.collection('users').snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => UserDTO.fromJson(doc.data()).copyWith(uid: doc.id))
          .where((user) =>
              user.name!.toLowerCase().contains(query.toLowerCase()) ||
              user.email!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Future<void> updateUserOnlineStatus({required bool isOnline}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);

    await userRef.update({
      'isOnline': isOnline,
      if (!isOnline) 'lastSeen': DateTime.now().toString(),
    });
  }

  @override
  Future<void> updateUserName({required String name}) {
    return _firestore.collection('users').doc(_userId).update({'name': name});
  }

  @override
  Future<void> updateUserStatusMessage({required String statusMessage}) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .update({'statusMessage': statusMessage});
  }

  @override
  Future<void> removeUserProfilePic() {
    final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);

    return userRef.update({'photoURL': ""});
  }

  @override
  Future<void> updateUserProfilePic({required String photoURL}) {
    final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);

    return userRef.update({'photoURL': photoURL});
  }
}
