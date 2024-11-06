import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  Expense({
    required this.senderUsername,
    required this.reveiverUsername,
    required this.paidBy,
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
    required this.timestamp,
  });
  final String senderUsername;
  final String reveiverUsername;
  final String paidBy;
  final String title;
  final double amount;
  final String date;
  final String time;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {
    return {
      'senderUsername': senderUsername,
      'reveiverUsername': reveiverUsername,
      'paidBy': paidBy,
      'title': title,
      'amount': amount,
      'date': date,
      'time': time,
      'timestamp': timestamp,
    };
  }
}
