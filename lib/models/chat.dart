import 'package:chatacter/models/message.dart';
import 'package:chatacter/models/user_data.dart';

class Chat {
  final Message message;
  final List<UserData> users;

  Chat({required this.message, required this.users});
}
