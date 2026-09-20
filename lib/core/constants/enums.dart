import 'package:flutter/material.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

enum BookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  rescheduled,
  cancelled,
  refunded,
}

extension BookingStatusX on BookingStatus {
  String toJson() {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.accepted:
        return 'accepted';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.rejected:
        return 'rejected';
      case BookingStatus.rescheduled:
        return 'rescheduled';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.refunded:
        return 'refunded';
    }
  }

  static BookingStatus fromJson(String value) {
    switch (value) {
      case 'pending':
        return BookingStatus.pending;
      case 'accepted':
        return BookingStatus.accepted;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'rejected':
        return BookingStatus.rejected;
      case 'rescheduled':
        return BookingStatus.rescheduled;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.pending;
    }
  }

  bool get isCustomerCancellationAllowed {
    switch (this) {
      case BookingStatus.pending:
      case BookingStatus.accepted:
        return true;
      default:
        return false;
    }
  }

  String get displayNameAr {
    switch (this) {
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.accepted:
        return 'مقبول';
      case BookingStatus.inProgress:
        return 'قيد التنفيذ';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.rejected:
        return 'مرفوض';
      case BookingStatus.rescheduled:
        return 'معاد جدولته';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.refunded:
        return 'مردود';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.accepted:
        return Colors.teal;
      case BookingStatus.inProgress:
        return SahelColors.violet;
      case BookingStatus.completed:
        return SahelColors.emerald;
      case BookingStatus.rejected:
        return SahelColors.rose;
      case BookingStatus.rescheduled:
        return Colors.teal;
      case BookingStatus.cancelled:
        return SahelColors.slate;
      case BookingStatus.refunded:
        return SahelColors.slate;
    }
  }
}

enum UserRole {
  customer,
  provider,
  admin,
}

extension UserRoleX on UserRole {
  String toJson() {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.provider:
        return 'provider';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromJson(String value) {
    switch (value) {
      case 'customer':
        return UserRole.customer;
      case 'provider':
        return UserRole.provider;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

enum CurrencyCode {
  yer,
  sar,
  usd,
}

extension CurrencyCodeX on CurrencyCode {
  String toJson() {
    switch (this) {
      case CurrencyCode.yer:
        return 'yer';
      case CurrencyCode.sar:
        return 'sar';
      case CurrencyCode.usd:
        return 'usd';
    }
  }

  static CurrencyCode fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'yer':
        return CurrencyCode.yer;
      case 'sar':
        return CurrencyCode.sar;
      case 'usd':
        return CurrencyCode.usd;
      default:
        return CurrencyCode.yer;
    }
  }

  String get symbol {
    switch (this) {
      case CurrencyCode.yer:
        return '﷼';
      case CurrencyCode.sar:
        return 'ر.س';
      case CurrencyCode.usd:
        return '\$';
    }
  }
}

enum LanguageCode {
  ar,
  en,
}

extension LanguageCodeX on LanguageCode {
  String toJson() {
    switch (this) {
      case LanguageCode.ar:
        return 'ar';
      case LanguageCode.en:
        return 'en';
    }
  }

  static LanguageCode fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'ar':
        return LanguageCode.ar;
      case 'en':
        return LanguageCode.en;
      default:
        return LanguageCode.ar;
    }
  }

  bool get isRTL => this == LanguageCode.ar;
}

enum ReviewType {
  clientToProvider,
  providerToClient,
}

extension ReviewTypeX on ReviewType {
  String toJson() {
    switch (this) {
      case ReviewType.clientToProvider:
        return 'client_to_provider';
      case ReviewType.providerToClient:
        return 'provider_to_client';
    }
  }

  static ReviewType fromJson(String value) {
    switch (value) {
      case 'client_to_provider':
        return ReviewType.clientToProvider;
      case 'provider_to_client':
        return ReviewType.providerToClient;
      default:
        return ReviewType.clientToProvider;
    }
  }
}

enum ComplaintStatus {
  pending,
  investigating,
  resolved,
  rejected,
}

extension ComplaintStatusX on ComplaintStatus {
  String toJson() {
    switch (this) {
      case ComplaintStatus.pending:
        return 'pending';
      case ComplaintStatus.investigating:
        return 'investigating';
      case ComplaintStatus.resolved:
        return 'resolved';
      case ComplaintStatus.rejected:
        return 'rejected';
    }
  }

  static ComplaintStatus fromJson(String value) {
    switch (value) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'investigating':
        return ComplaintStatus.investigating;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'rejected':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.pending;
    }
  }
}

enum WalletTransactionType {
  topup,
  payout,
  payment,
  refund,
  commission,
  earning,
}

extension WalletTransactionTypeX on WalletTransactionType {
  String toJson() {
    switch (this) {
      case WalletTransactionType.topup:
        return 'topup';
      case WalletTransactionType.payout:
        return 'payout';
      case WalletTransactionType.payment:
        return 'payment';
      case WalletTransactionType.refund:
        return 'refund';
      case WalletTransactionType.commission:
        return 'commission';
      case WalletTransactionType.earning:
        return 'earning';
    }
  }

  static WalletTransactionType fromJson(String value) {
    switch (value) {
      case 'topup':
        return WalletTransactionType.topup;
      case 'payout':
        return WalletTransactionType.payout;
      case 'payment':
        return WalletTransactionType.payment;
      case 'refund':
        return WalletTransactionType.refund;
      case 'commission':
        return WalletTransactionType.commission;
      case 'earning':
        return WalletTransactionType.earning;
      default:
        return WalletTransactionType.payment;
    }
  }
}

enum MessageStatus {
  sent,
  delivered,
  read,
}

extension MessageStatusX on MessageStatus {
  String toJson() {
    switch (this) {
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
    }
  }

  static MessageStatus fromJson(String? value) {
    switch (value) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}
