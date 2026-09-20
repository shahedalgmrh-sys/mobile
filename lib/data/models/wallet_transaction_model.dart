import 'package:json_annotation/json_annotation.dart';

import 'package:saber_flutter/core/constants/enums.dart';

part 'wallet_transaction_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WalletTransaction {
  final int id;
  final String txnId;
  final int userId;
  final WalletTransactionType type;
  final double amount;
  final String currencyCode;
  final String? reference;
  final String? status;
  final int? bookingId;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.txnId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currencyCode,
    this.reference,
    this.status,
    this.bookingId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);

  WalletTransaction copyWith({
    int? id,
    String? txnId,
    int? userId,
    WalletTransactionType? type,
    double? amount,
    String? currencyCode,
    String? reference,
    String? status,
    int? bookingId,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      txnId: txnId ?? this.txnId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
