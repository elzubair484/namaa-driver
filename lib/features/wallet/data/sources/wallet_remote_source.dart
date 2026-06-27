import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/withdrawal_entity.dart';

class WalletRemoteSource {
  WalletRemoteSource(this._client);
  final SupabaseClient _client;

  Future<WalletEntity> getWallet(String driverId) async {
    try {
      final data = await _client
          .from('driver_wallets')
          .select()
          .eq('driver_id', driverId)
          .single();
      return _walletFromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Stream<WalletEntity?> watchWallet(String driverId) {
    return _client
        .from('driver_wallets')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .map((rows) => rows.isEmpty ? null : _walletFromJson(rows.first));
  }

  Future<List<TransactionEntity>> getTransactions(
    String driverId, {
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final wallet = await getWallet(driverId);
      final data = await _client
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', wallet.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return (data as List).map(_txFromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<List<WithdrawalEntity>> getWithdrawals(String driverId) async {
    try {
      final data = await _client
          .from('withdrawal_requests')
          .select()
          .eq('driver_id', driverId)
          .order('requested_at', ascending: false)
          .limit(10);
      return (data as List).map(_withdrawalFromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<WithdrawalEntity> requestWithdrawal({
    required String driverId,
    required String walletId,
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final data = await _client
          .from('withdrawal_requests')
          .insert({
            'driver_id': driverId,
            'wallet_id': walletId,
            'amount': amount,
            'bank_name': bankName,
            'account_number': accountNumber,
            'account_name': accountName,
          })
          .select()
          .single();
      return _withdrawalFromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  // ── Earnings breakdown from trips ────────────────────────────

  Future<Map<String, double>> getEarningsBreakdown(String driverId) async {
    try {
      final now = DateTime.now();

      final startToday =
          DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
      final startWeek = now
          .subtract(Duration(days: now.weekday - 1))
          .copyWith(hour: 0, minute: 0, second: 0)
          .toUtc()
          .toIso8601String();
      final startMonth =
          DateTime(now.year, now.month, 1).toUtc().toIso8601String();

      final rows = await _client
          .from('trips')
          .select('driver_earnings, completed_at')
          .eq('driver_id', driverId)
          .eq('status', 'completed')
          .gte('completed_at', startMonth);

      double today = 0, week = 0, month = 0;
      for (final row in rows as List) {
        final amt = (row['driver_earnings'] as num?)?.toDouble() ?? 0;
        final at = DateTime.tryParse(row['completed_at'] as String? ?? '');
        if (at == null) continue;
        month += amt;
        if (at.toUtc().toIso8601String().compareTo(startWeek) >= 0) week += amt;
        if (at.toUtc().toIso8601String().compareTo(startToday) >= 0) today += amt;
      }

      return {'today': today, 'week': week, 'month': month};
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  // ── Parsers ───────────────────────────────────────────────────

  WalletEntity _walletFromJson(Map<String, dynamic> j) => WalletEntity(
        id: j['id'] as String,
        driverId: j['driver_id'] as String,
        balance: (j['balance'] as num?)?.toDouble() ?? 0,
        totalEarned: (j['total_earned'] as num?)?.toDouble() ?? 0,
        totalWithdrawn: (j['total_withdrawn'] as num?)?.toDouble() ?? 0,
        totalCommission: (j['total_commission'] as num?)?.toDouble() ?? 0,
        pendingWithdrawal: (j['pending_withdrawal'] as num?)?.toDouble() ?? 0,
        updatedAt:
            DateTime.tryParse(j['updated_at'] as String? ?? '') ?? DateTime.now(),
      );

  TransactionEntity _txFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return TransactionEntity(
      id: m['id'] as String,
      type: TransactionType.fromDb(m['type'] as String?),
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      balanceBefore: (m['balance_before'] as num?)?.toDouble() ?? 0,
      balanceAfter: (m['balance_after'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
      description: m['description'] as String?,
      tripId: m['trip_id'] as String?,
    );
  }

  WithdrawalEntity _withdrawalFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return WithdrawalEntity(
      id: m['id'] as String,
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      status: WithdrawalStatus.fromDb(m['status'] as String?),
      bankName: m['bank_name'] as String,
      accountNumber: m['account_number'] as String,
      accountName: m['account_name'] as String,
      requestedAt:
          DateTime.tryParse(m['requested_at'] as String? ?? '') ?? DateTime.now(),
      rejectionReason: m['rejection_reason'] as String?,
      processedAt: DateTime.tryParse(m['processed_at'] as String? ?? ''),
    );
  }
}
