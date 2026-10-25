// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: (json['id'] as num).toInt(),
      threadId: json['threadId'] as String,
      senderId: (json['senderId'] as num).toInt(),
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'senderId': instance.senderId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'status': _$MessageStatusEnumMap[instance.status],
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MessageStatusEnumMap = {
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
};
