import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/dto/user_dto.dart';
import 'package:chitchat/core/errors/firebase_error_handler.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/core/providers/firebase_firestore_provider.dart';
import 'package:chitchat/features/auth/domain/repositories/auth_repository_interface.dart';

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  final auth = ref.watch(authProvider);
  final firestore = ref.watch(firestoreProvider);

  return AuthRepository(auth, firestore);
});

class AuthRepository implements AuthRepositoryInterface {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  @override
  Future<String?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return 'Error while logging in. Please try again.';
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      await userRef.update({'isOnline': true});

      return null;
    } on FirebaseAuthException catch (e) {
      return FirebaseErrorHandler.handleAuthError(e);
    } on FirebaseException catch (e) {
      return FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      return FirebaseErrorHandler.handleGenericError(e);
    }
  }

  @override
  Future<String?> registerWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return 'Error while registering. Please try again.';
      }

      final userRef = _firestore.collection('users').doc(user.uid);

      final userData = UserDTO(
        name: name,
        email: user.email,
        photoURL: user.photoURL ?? '',
        createdAt: DateTime.now().toString(),
        isOnline: true,
        lastSeen: null,
        friends: [],
        friendRequests: [],
        fcmToken: '',
        statusMessage: '',
      ).toJson();

      await userRef.set(userData);

      return null;
    } on FirebaseAuthException catch (e) {
      return FirebaseErrorHandler.handleAuthError(e);
    } on FirebaseException catch (e) {
      return FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      return FirebaseErrorHandler.handleGenericError(e);
    }
  }

  @override
  Future<void> logout() async {
    // setting user to offline
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
    await userRef.update({'isOnline': false});
    await _auth.signOut();
  }
}
