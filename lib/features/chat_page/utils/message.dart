
class Message {
  DateTime time;
  String? content;
  String receiverName;
  String receiverId;
  String senderName;
  String senderId;
  bool seen;
  bool myMessage;
  String? photoUrl;
  int? unseenMsgCounter;
  String? messageId;

  Message({
    required this.time,
    required this.content,
    required this.seen,
    required this.myMessage,
    required this.receiverId,
    required this.receiverName,
    required this.senderId,
    required this.senderName,
    required this.photoUrl,
    required this.unseenMsgCounter,
    required this.messageId,
  });
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'content': content,
      'seen': seen,
      'myMessage': myMessage,
      'receiverId': receiverId,
      'senderId': senderId,
      'photoUrl': photoUrl,
      'senderName': senderName,
      'receiverName': receiverName,
      'unseenMsgCounter': unseenMsgCounter,
      'messageId': messageId,
    };
  }
}
