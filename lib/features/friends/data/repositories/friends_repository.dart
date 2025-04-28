import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/core/providers/firebase_firestore_provider.dart';
import 'package:chitchat/features/friends/domain/friends_repository_interface.dart';

final friendsRepositoryProvider = Provider<FriendsRepositoryInterface>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final currentUser = ref.watch(currentUserProvider).asData?.value;

  return FriendsRepository(firestore, currentUser!.uid);
});

class FriendsRepository implements FriendsRepositoryInterface {
  final FirebaseFirestore _firestore;
  final String _userId;

  FriendsRepository(this._firestore, this._userId);

  @override
  Stream<List<String>?> getFriends() {
    return _firestore.collection('users').doc(_userId).snapshots().map((doc) {
      return List<String>.from(doc.data()?['friends'] ?? []);
    });
  }

  @override
  Stream<List<String>?> getFriendsRequests() {
    return _firestore.collection('users').doc(_userId).snapshots().map((doc) {
      return List<String>.from(doc.data()?['friendRequests'] ?? []);
    });
  }

  @override
  Future<void> removeFriend(String friendId) async {
    final userRef = _firestore.collection('users').doc(_userId);
    final friendRef = _firestore.collection('users').doc(friendId);
    final chatQuery = await _firestore
        .collection('chats')
        .where('type', isEqualTo: 'private')
        .where('participants', arrayContains: _userId)
        .get();

    String? chatId;
    for (var doc in chatQuery.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(friendId)) {
        chatId = doc.id;
        break;
      }
    }

    await userRef.update({
      'friends': FieldValue.arrayRemove([friendId]),
    });

    await friendRef.update({
      'friends': FieldValue.arrayRemove([_userId]),
    });

    if (chatId != null) {
      final messagesRef =
          _firestore.collection('messages').doc(chatId).collection('messages');

      final messagesSnapshot = await messagesRef.get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('chats').doc(chatId).delete();
      await _firestore.collection('messages').doc(chatId).delete();
    }
  }

  @override
  Future<void> sendFriendRequest(String friendId) {
    final userRef = _firestore.collection('users').doc(friendId);

    return userRef.update({
      'friendRequests': FieldValue.arrayUnion([_userId]),
    });
  }

  @override
  Future<void> acceptFriendRequest(String friendId) async {
    // adding the friend to the user's friends list
    final userRef = _firestore.collection('users').doc(_userId);
    await userRef.update({
      'friends': FieldValue.arrayUnion([friendId]),
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });

    // adding the user to the friend's friends list
    final friendRef = _firestore.collection('users').doc(friendId);
    await friendRef.update({
      'friends': FieldValue.arrayUnion([_userId]),
      'friendRequests': FieldValue.arrayRemove([_userId]),
    });

    // verify if the chat already exists
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: _userId)
        .get();

    final existingChat = chatQuery.docs.any((doc) {
      final participants = List<String>.from(doc['participants']);
      return participants.contains(friendId);
    });

    // If the chat does not exist, create a new one
    if (!existingChat) {
      await _firestore.collection('chats').add({
        'type': 'private',
        'participants': [_userId, friendId],
        'createdAt': DateTime.now().toString(),
      });
    }
  }

  @override
  Future<void> rejectFriendRequest(String friendId) {
    final userRef = _firestore.collection('users').doc(_userId);

    return userRef.update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });
  }

  @override
  Stream<List<UserDTO>> searchFriends(String query) async* {
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final List<String> friendIds =
        List<String>.from(userDoc.data()?['friends'] ?? []);

    yield* _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => UserDTO.fromJson(doc.data()).copyWith(uid: doc.id))
          .where((friend) =>
              friend.name!.toLowerCase().contains(query.toLowerCase()) ||
              friend.email!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Future<bool> isFriend(String friendId) async {
    final userRef = _firestore.collection('users').doc(_userId);

    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) return false;

    final List<String> friends =
        List<String>.from(userSnapshot.data()?['friends'] ?? []);

    return friends.contains(friendId);
  }
}
