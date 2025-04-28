class ChatDTO {
  String? id;
  String? type;
  String? groupName;
  String? groupPhotoURL;
  List<String>? admins;
  List<String>? participants;
  MessageDTO? lastMessage;
  String? createdAt;

  ChatDTO(
      {this.id,
      this.type,
      this.groupName,
      this.groupPhotoURL,
      this.admins,
      this.participants,
      this.lastMessage,
      this.createdAt});

  ChatDTO.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'private') {
      id = json['id'];
      type = json['type'];
      participants = json['participants'].cast<String>();
      lastMessage = json['lastMessage'] != null
          ? MessageDTO.fromJson(json['lastMessage'])
          : null;
      createdAt = json['createdAt'];
    } else if (json['type'] == 'group') {
      id = json['id'];
      type = json['type'];
      groupName = json['groupName'];
      groupPhotoURL = json['groupPhotoURL'];
      admins = json['admins'].cast<String>();
      participants = json['participants'].cast<String>();
      lastMessage = json['lastMessage'] != null
          ? MessageDTO.fromJson(json['lastMessage'])
          : null;
      createdAt = json['createdAt'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['groupName'] = groupName;
    data['groupPhotoURL'] = groupPhotoURL;
    data['admins'] = admins;
    data['participants'] = participants;
    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }
    data['createdAt'] = createdAt;
    return data;
  }

  ChatDTO copyWith({
    String? id,
    String? type,
    String? groupName,
    String? groupPhotoURL,
    List<String>? admins,
    List<String>? participants,
    MessageDTO? lastMessage,
    String? createdAt,
  }) =>
      ChatDTO(
        id: id ?? this.id,
        type: type ?? this.type,
        groupName: groupName ?? this.groupName,
        groupPhotoURL: groupPhotoURL ?? this.groupPhotoURL,
        admins: admins ?? this.admins,
        participants: participants ?? this.participants,
        lastMessage: lastMessage ?? this.lastMessage,
        createdAt: createdAt ?? this.createdAt,
      );
}

class MessageDTO {
  String? senderId;
  String? text;
  String? timestamp;
  String? messageType;
  List<String>? seenBy;

  MessageDTO(
      {this.senderId,
      this.text,
      this.timestamp,
      this.messageType,
      this.seenBy});

  MessageDTO.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    text = json['text'];
    timestamp = json['timestamp'];
    messageType = json['messageType'];
    if (json['seenBy'] != null) {
      seenBy = json['seenBy'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['text'] = text;
    data['timestamp'] = timestamp;
    data['messageType'] = messageType;
    if (seenBy != null) {
      data['seenBy'] = seenBy;
    }
    return data;
  }
}
