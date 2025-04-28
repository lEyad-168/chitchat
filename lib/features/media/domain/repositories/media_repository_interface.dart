import 'dart:io';

abstract interface class MediaRepositoryInterface {
  Future<String?> uploadMedia(File mediaFile, {required bool isVideo});
}
