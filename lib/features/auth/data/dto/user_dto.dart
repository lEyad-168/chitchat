class UserDTO {
  String? uid;
  String? email;
  String? photoURL;
  String? name;
  List<String>? friends;
  List<String>? friendRequests;
  String? createdAt;
  String? lastSeen;
  bool? isOnline;
  String? fcmToken;
  String? statusMessage;

  UserDTO(
      {this.email,
      this.uid,
      this.photoURL,
      this.name,
      this.friends,
      this.friendRequests,
      this.createdAt,
      this.lastSeen,
      this.isOnline,
      this.fcmToken,
      this.statusMessage});

  UserDTO.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    email = json['email'];
    photoURL = json['photoURL'];
    name = json['name'];
    friends = json['friends'].cast<String>();
    friendRequests = json['friendRequests'].cast<String>();
    createdAt = json['createdAt'];
    lastSeen = json['lastSeen'];
    isOnline = json['isOnline'];
    fcmToken = json['fcmToken'];
    statusMessage = json['statusMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['photoURL'] = photoURL;
    data['name'] = name;
    data['friends'] = friends;
    data['friendRequests'] = friendRequests;
    data['createdAt'] = createdAt;
    data['lastSeen'] = lastSeen;
    data['isOnline'] = isOnline;
    data['fcmToken'] = fcmToken;
    data['statusMessage'] = statusMessage;
    return data;
  }

  UserDTO copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    String? createdAt,
    bool? isOnline,
    String? lastSeen,
    List<String>? friends,
    List<String>? friendRequests,
    String? fcmToken,
    String? statusMessage,
  }) {
    return UserDTO(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      fcmToken: fcmToken ?? this.fcmToken,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
