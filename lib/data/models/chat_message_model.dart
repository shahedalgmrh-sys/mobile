import 'package:json_annotation/json_annotation.dart';

import 'package:saber_flutter/core/constants/enums.dart';

part 'chat_message_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatMessage {
  final int id;
  final String threadId;
  final int senderId;
  final String content;
  final String? imageUrl;
  final MessageStatus? status;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    this.imageUrl,
    this.status,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    int? id,
    String? threadId,
    int? senderId,
    String? content,
    String? imageUrl,
    MessageStatus? status,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
