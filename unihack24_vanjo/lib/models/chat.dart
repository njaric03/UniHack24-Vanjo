import 'message.dart';

class Chat {
  String chatId;
  List<Message> messages;

  Chat({
    required this.chatId,
    required this.messages,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      chatId: map['chatId'],
      messages: (map['messages'] as List<dynamic>)
          .map((message) => Message.fromMap(message as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }
}
