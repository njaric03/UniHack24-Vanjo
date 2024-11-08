import 'package:unihack24_vanjo/models/message.dart';

class Chat {
  List<Message> messages; // This will now hold only the most recent messages
  String participant1;
  String participant2;

  Chat({
    required this.messages,
    required this.participant1,
    required this.participant2,
    required String chatId,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      messages: [],
      participant1: map['participant1'],
      participant2: map['participant2'],
      chatId: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participant1': participant1,
      'participant2': participant2,
    };
  }
}
