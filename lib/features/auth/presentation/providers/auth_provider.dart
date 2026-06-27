import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/providers.dart';
import '../../data/sources/auth_remote_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteSourceProvider = Provider<AuthRemoteSource>((ref) {
  return AuthRemoteSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteSourceProvider));
});

final currentDriverProvider = StreamProvider<DriverEntity?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentDriver();
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session);
});

class SendOtpState {
  const SendOtpState({this.isLoading = false, this.error, this.sent = false});
  final bool isLoading;
  final String? error;
  final bool sent;
}

class SendOtpNotifier extends AsyncNotifier<SendOtpState> {
  @override
  Future<SendOtpState> build() async => const SendOtpState();

  Future<void> send(String phone) async {
    state = const AsyncValue.data(SendOtpState(isLoading: true));
    final result = await ref.read(authRepositoryProvider).sendOtp(phone);
    result.fold(
      (failure) => state = AsyncValue.data(SendOtpState(error: failure.message)),
      (_) => state = const AsyncValue.data(SendOtpState(sent: true)),
    );
  }
}

final sendOtpProvider =
    AsyncNotifierProvider<SendOtpNotifier, SendOtpState>(SendOtpNotifier.new);

class VerifyOtpNotifier extends AsyncNotifier<DriverEntity?> {
  @override
  Future<DriverEntity?> build() async => null;

  Future<bool> verify({required String phone, required String otp}) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(phone: phone, otp: otp);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (driver) {
        state = AsyncValue.data(driver);
        return true;
      },
    );
  }
}

final verifyOtpProvider =
    AsyncNotifierProvider<VerifyOtpNotifier, DriverEntity?>(VerifyOtpNotifier.new);
