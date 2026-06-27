import 'package:equatable/equatable.dart';

enum TransactionType {
  tripEarning,
  commissionDeduction,
  withdrawal,
  bonus,
  refund,
  adjustment;

  static TransactionType fromDb(String? s) => switch (s) {
        'trip_earning' => TransactionType.tripEarning,
        'commission_deduction' => TransactionType.commissionDeduction,
        'withdrawal' => TransactionType.withdrawal,
        'bonus' => TransactionType.bonus,
        'refund' => TransactionType.refund,
        _ => TransactionType.adjustment,
      };

  String get labelAr => switch (this) {
        TransactionType.tripEarning => 'أرباح رحلة',
        TransactionType.commissionDeduction => 'عمولة',
        TransactionType.withdrawal => 'سحب',
        TransactionType.bonus => 'مكافأة',
        TransactionType.refund => 'استرداد',
        TransactionType.adjustment => 'تعديل',
      };

  bool get isCredit => switch (this) {
        TransactionType.tripEarning => true,
        TransactionType.bonus => true,
        TransactionType.refund => true,
        _ => false,
      };
}

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
    this.description,
    this.tripId,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;
  final String? description;
  final String? tripId;

  @override
  List<Object?> get props => [id];
}
