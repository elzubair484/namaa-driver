import 'package:equatable/equatable.dart';

enum WithdrawalStatus {
  pending,
  approved,
  processing,
  completed,
  rejected;

  static WithdrawalStatus fromDb(String? s) => switch (s) {
        'approved' => WithdrawalStatus.approved,
        'processing' => WithdrawalStatus.processing,
        'completed' => WithdrawalStatus.completed,
        'rejected' => WithdrawalStatus.rejected,
        _ => WithdrawalStatus.pending,
      };

  String get labelAr => switch (this) {
        WithdrawalStatus.pending => 'قيد المراجعة',
        WithdrawalStatus.approved => 'مقبول',
        WithdrawalStatus.processing => 'جارٍ التحويل',
        WithdrawalStatus.completed => 'مكتمل',
        WithdrawalStatus.rejected => 'مرفوض',
      };
}

class WithdrawalEntity extends Equatable {
  const WithdrawalEntity({
    required this.id,
    required this.amount,
    required this.status,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.requestedAt,
    this.rejectionReason,
    this.processedAt,
  });

  final String id;
  final double amount;
  final WithdrawalStatus status;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final DateTime requestedAt;
  final String? rejectionReason;
  final DateTime? processedAt;

  @override
  List<Object?> get props => [id, status];
}
