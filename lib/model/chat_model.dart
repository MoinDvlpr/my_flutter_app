// Chat Message Model
import '../utils/app_constant.dart';

class ChatMessage {
  final int? chatMsgID;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    this.chatMsgID,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      CHAT_MSG_ID: chatMsgID,
      MESSAGE: message,
      IS_USER: isUser ? 1 : 0,
      TIMESTAMP: timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
        chatMsgID: map[CHAT_MSG_ID] as int?,
      message: map[MESSAGE] as String,
      isUser: (map[IS_USER] as int) == 1,
      timestamp: DateTime.parse(map[TIMESTAMP] as String),
    );
  }

  // Convert to Groq API format
  Map<String, dynamic> toGroqFormat() {
    return {
      ROLE: isUser ? 'user' : 'system',
      CONTENT: message,
    };
  }
}