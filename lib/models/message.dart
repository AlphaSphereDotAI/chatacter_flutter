class Message {
  final String message;
  final String sender;
  final String receiver;
  final String? id;
  final DateTime timestamp;
  final bool isSeenByReceiver;
  final bool? isImage;

  Message(
      {required this.message,
      required this.sender,
      required this.receiver,
      this.id,
      required this.timestamp,
      required this.isSeenByReceiver,
      this.isImage});

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      message: map['message'],
      sender: map['sender_id'],
      receiver: map['receiver_id'],
      timestamp: DateTime.parse(map['timestamp']),
      isSeenByReceiver: map['is_seen_by_receiver'],
      id: map['\$id'],
      isImage: map['is_image'],
    );
  }
}
