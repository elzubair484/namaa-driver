import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/data/sources/onboarding_remote_source.dart';

final onboardingSourceForProfileProvider =
    Provider<OnboardingRemoteSource>((ref) {
  return OnboardingRemoteSource(ref.watch(supabaseClientProvider));
});

class EditProfileState {
  const EditProfileState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.avatarFile,
  });
  final bool isLoading;
  final String? error;
  final bool success;
  final XFile? avatarFile;

  EditProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    XFile? avatarFile,
    bool clearError = false,
  }) =>
      EditProfileState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        success: success ?? this.success,
        avatarFile: avatarFile ?? this.avatarFile,
      );
}

class EditProfileNotifier extends AutoDisposeNotifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  void pickAvatar(XFile file) {
    state = state.copyWith(avatarFile: file, clearError: true);
  }

  Future<void> save({
    required String fullName,
    required String? email,
  }) async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;

    state = state.copyWith(isLoading: true, clearError: true, success: false);

    try {
      final source = ref.read(onboardingSourceForProfileProvider);

      String? avatarUrl;
      if (state.avatarFile != null) {
        avatarUrl = await source.uploadAvatar(
          userId: driver.userId,
          file: state.avatarFile,
        );
      }

      await source.updateDriverProfile(
        driverId: driver.id,
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
      );

      // Refresh driver data
      ref.invalidate(currentDriverProvider);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final editProfileProvider =
    AutoDisposeNotifierProvider<EditProfileNotifier, EditProfileState>(
        EditProfileNotifier.new);
