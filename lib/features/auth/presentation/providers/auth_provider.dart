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

class SignInNotifier extends AsyncNotifier<DriverEntity?> {
  @override
  Future<DriverEntity?> build() async => null;

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: email, password: password);
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

final signInProvider =
    AsyncNotifierProvider<SignInNotifier, DriverEntity?>(SignInNotifier.new);
