import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';

final markMessageAsSeenProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return (chatId, messageId) {
    return chatRepository.markMessageAsSeen(chatId, messageId);
  };
});
