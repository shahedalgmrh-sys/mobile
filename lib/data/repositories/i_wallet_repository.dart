import '../models/wallet_transaction_model.dart';

class WalletBalance {
  final double balance;
  final String currencyCode;
  final double totalEarnings;
  final double pendingAmount;

  const WalletBalance({
    required this.balance,
    required this.currencyCode,
    required this.totalEarnings,
    required this.pendingAmount,
  });
}

class TopupResult {
  final String transactionId;
  final double amount;
  final String paymentUrl;
  final String status;

  const TopupResult({
    required this.transactionId,
    required this.amount,
    required this.paymentUrl,
    required this.status,
  });
}

class PayoutResult {
  final String transactionId;
  final double amount;
  final String status;
  final DateTime? estimatedArrival;

  const PayoutResult({
    required this.transactionId,
    required this.amount,
    required this.status,
    this.estimatedArrival,
  });
}

class WalletStatement {
  final List<WalletTransaction> transactions;
  final int totalCount;
  final int currentPage;
  final int lastPage;
  final double totalCredits;
  final double totalDebits;

  const WalletStatement({
    required this.transactions,
    required this.totalCount,
    required this.currentPage,
    required this.lastPage,
    required this.totalCredits,
    required this.totalDebits,
  });
}

abstract class IWalletRepository {
  Future<WalletBalance> getBalance();

  Future<TopupResult> topup(double amount, String paymentMethod);

  Future<PayoutResult> payout(Map<String, dynamic> bankDetails);

  Future<WalletStatement> statement({
    int? page,
    int? perPage,
    String? type,
    DateTime? from,
    DateTime? to,
  });
}
