import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message({
    required this.senderUsername,
    required this.receiverUsername,
    required this.message,
    required this.timestamp,
  });
  final String senderUsername;
  final String receiverUsername;
  final String message;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {  
    return {
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
