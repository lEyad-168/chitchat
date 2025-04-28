import 'package:chitchat/features/chat/data/dto/chat_dto.dart';
import 'package:chitchat/features/users/domain/user_repository_interface.dart';

abstract interface class ChatRepositoryInterface {
  Stream<List<ChatDTO>?> getChats();
  Stream<List<ChatDTO>> searchChats(String query);
  Stream<ChatDTO?> getChatDetails(String chatId);
  Future<String?> getPrivateChatIdByFriendId(String friendId);
  Stream<int> getUnseenMessagesCount(String chatId);
  Stream<List<MessageDTO>?> getMessages(String chatId);
  Future<MessageDTO?> sendMessage(
    String chatId,
    String message,
    bool isMedia,
    bool isVideo,
  );
  Future<void> markMessageAsSeen(String chatId, String messageId);
  Future<void> createPrivateChat(String friendId);
  Future<String> createGroupChat(
      {required String groupName,
      required String groupPhotoURL,
      required List<String> participants});
  Future<void> deleteChat(String chatId);
  Future<String?> getChatPhotoURL(
      ChatDTO chat, UserRepositoryInterface userRepo);
  Stream<int> getNumberOfOnlineMembers(String chatId);
  Future<void> deleteAllPrivateChats();
  Future<void> leftAllGroupChats();
}
