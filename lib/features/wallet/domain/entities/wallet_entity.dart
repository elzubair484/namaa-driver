import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  const WalletEntity({
    required this.id,
    required this.driverId,
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.totalCommission,
    required this.pendingWithdrawal,
    required this.updatedAt,
  });

  final String id;
  final String driverId;
  final double balance;
  final double totalEarned;
  final double totalWithdrawn;
  final double totalCommission;
  final double pendingWithdrawal;
  final DateTime updatedAt;

  double get availableBalance => balance - pendingWithdrawal;

  @override
  List<Object?> get props => [id, balance, pendingWithdrawal];
}
