import 'package:chatacter/models/user_data.dart';

class Post {
  final String? id;
  final String? message;
  final UserData? owner;
  final DateTime? timeStamp;
  final String? image;

  Post(
      {required this.id,
      required this.message,
      required this.owner,
      required this.timeStamp,
      required this.image});

  // To convert document data to user data
  factory Post.toMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      owner: map['owner_id'] ?? '',
      timeStamp: map['time_stamp'] ?? '',
      image: map['image'] ?? '',
    );
  }
}
