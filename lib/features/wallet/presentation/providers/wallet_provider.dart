import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/wallet_remote_source.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/withdrawal_entity.dart';

final walletRemoteSourceProvider = Provider<WalletRemoteSource>((ref) {
  return WalletRemoteSource(ref.watch(supabaseClientProvider));
});

// Live wallet balance stream
final walletProvider = StreamProvider<WalletEntity?>((ref) {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return Stream.value(null);
  return ref.watch(walletRemoteSourceProvider).watchWallet(driver.id);
});

// Paginated transactions
final transactionsProvider =
    FutureProvider<List<TransactionEntity>>((ref) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return [];
  return ref.read(walletRemoteSourceProvider).getTransactions(driver.id);
});

// Withdrawal history
final withdrawalsProvider =
    FutureProvider<List<WithdrawalEntity>>((ref) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return [];
  return ref.read(walletRemoteSourceProvider).getWithdrawals(driver.id);
});

// Earnings breakdown today/week/month
final earningsBreakdownProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final driver = ref.watch(currentDriverProvider).valueOrNull;
  if (driver == null) return {'today': 0, 'week': 0, 'month': 0};
  return ref.read(walletRemoteSourceProvider).getEarningsBreakdown(driver.id);
});

// Withdrawal request notifier
class WithdrawalNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<WithdrawalEntity?> request({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    final wallet = ref.read(walletProvider).valueOrNull;
    if (driver == null || wallet == null) return null;

    state = const AsyncLoading();
    WithdrawalEntity? result;
    state = await AsyncValue.guard(() async {
      result = await ref.read(walletRemoteSourceProvider).requestWithdrawal(
            driverId: driver.id,
            walletId: wallet.id,
            amount: amount,
            bankName: bankName,
            accountNumber: accountNumber,
            accountName: accountName,
          );
    });
    // Refresh withdrawals list
    ref.invalidate(withdrawalsProvider);
    return result;
  }
}

final withdrawalNotifierProvider =
    AsyncNotifierProvider<WithdrawalNotifier, void>(WithdrawalNotifier.new);
