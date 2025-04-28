import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/services/cloud_services.dart';
import 'package:chitchat/features/media/domain/repositories/media_repository_interface.dart';

final mediaRepositoryProvider = Provider<MediaRepositoryInterface>((ref) {
  final cloudService = ref.watch(firebaseStorageProvider);

  return MediaRepository(cloudService);
});

class MediaRepository implements MediaRepositoryInterface {
  final FirebaseStorageService _storageService;

  MediaRepository(this._storageService);

  @override
  Future<String?> uploadMedia(File mediaFile, {required bool isVideo}) {
    return _storageService.uploadMedia(mediaFile, isVideo: isVideo);
  }
}
