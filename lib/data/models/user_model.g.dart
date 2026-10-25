// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      avatar: json['avatar'] as String?,
      walletBalance: (json['walletBalance'] as num).toDouble(),
      languageCode: json['languageCode'] as String,
      currencyCode: json['currencyCode'] as String,
      isVerified: json['isVerified'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'avatar': instance.avatar,
      'walletBalance': instance.walletBalance,
      'languageCode': instance.languageCode,
      'currencyCode': instance.currencyCode,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.provider: 'provider',
  UserRole.admin: 'admin',
};
