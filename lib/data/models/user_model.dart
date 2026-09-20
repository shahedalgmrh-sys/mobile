import 'package:json_annotation/json_annotation.dart';

import 'package:saber_flutter/core/constants/enums.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final UserRole role;
  final String? avatar;
  final double walletBalance;
  final String languageCode;
  final String currencyCode;
  final bool isVerified;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.role,
    this.avatar,
    required this.walletBalance,
    required this.languageCode,
    required this.currencyCode,
    required this.isVerified,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatar,
    double? walletBalance,
    String? languageCode,
    String? currencyCode,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      walletBalance: walletBalance ?? this.walletBalance,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
