// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    WalletTransaction(
      id: (json['id'] as num).toInt(),
      txnId: json['txnId'] as String,
      userId: (json['userId'] as num).toInt(),
      type: $enumDecode(_$WalletTransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      reference: json['reference'] as String?,
      status: json['status'] as String?,
      bookingId: (json['bookingId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WalletTransactionToJson(WalletTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'txnId': instance.txnId,
      'userId': instance.userId,
      'type': _$WalletTransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'currencyCode': instance.currencyCode,
      'reference': instance.reference,
      'status': instance.status,
      'bookingId': instance.bookingId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$WalletTransactionTypeEnumMap = {
  WalletTransactionType.topup: 'topup',
  WalletTransactionType.payout: 'payout',
  WalletTransactionType.payment: 'payment',
  WalletTransactionType.refund: 'refund',
  WalletTransactionType.commission: 'commission',
  WalletTransactionType.earning: 'earning',
};
