import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/dto/user_dto.dart';

final friendsListToCreateGroupProvider =
    StateProvider<List<UserDTO>>((ref) => []);
