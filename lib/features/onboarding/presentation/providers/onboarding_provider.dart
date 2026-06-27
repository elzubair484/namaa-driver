import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/domain/entities/driver_entity.dart';
import '../../data/sources/onboarding_remote_source.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';

final onboardingRemoteSourceProvider = Provider<OnboardingRemoteSource>((ref) {
  return OnboardingRemoteSource(ref.watch(supabaseClientProvider));
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingRemoteSourceProvider));
});

// ── Profile Setup ──────────────────────────────────────────────

class ProfileSetupState {
  const ProfileSetupState({
    this.isLoading = false,
    this.error,
    this.driver,
    this.avatarFile,
    this.avatarUrl,
  });
  final bool isLoading;
  final String? error;
  final DriverEntity? driver;
  final dynamic avatarFile;
  final String? avatarUrl;

  ProfileSetupState copyWith({
    bool? isLoading,
    String? error,
    DriverEntity? driver,
    dynamic avatarFile,
    String? avatarUrl,
  }) =>
      ProfileSetupState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        driver: driver ?? this.driver,
        avatarFile: avatarFile ?? this.avatarFile,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  void setAvatarFile(dynamic file) =>
      state = state.copyWith(avatarFile: file, error: null);

  Future<bool> submit({
    required String fullName,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = ref.read(onboardingRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final phone = Supabase.instance.client.auth.currentUser!.phone ?? '';

    String? avatarUrl;
    if (state.avatarFile != null) {
      final upload = await repo.uploadAvatar(
        userId: userId,
        imageFile: state.avatarFile,
      );
      upload.fold((f) => null, (url) => avatarUrl = url);
    }

    final result = await repo.createDriverProfile(
      fullName: fullName,
      phone: phone,
      email: email,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (driver) async {
        if (avatarUrl != null) {
          await repo.updateDriverProfile(
            driverId: driver.id,
            avatarUrl: avatarUrl,
          );
        }
        state = state.copyWith(isLoading: false, driver: driver);
        return true;
      },
    );
  }
}

final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
        ProfileSetupNotifier.new);

// ── Vehicle Info ───────────────────────────────────────────────

class VehicleInfoState {
  const VehicleInfoState({
    this.isLoading = false,
    this.error,
    this.vehicle,
    this.vehicleType = VehicleType.economy,
  });
  final bool isLoading;
  final String? error;
  final VehicleEntity? vehicle;
  final VehicleType vehicleType;

  VehicleInfoState copyWith({
    bool? isLoading,
    String? error,
    VehicleEntity? vehicle,
    VehicleType? vehicleType,
  }) =>
      VehicleInfoState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        vehicle: vehicle ?? this.vehicle,
        vehicleType: vehicleType ?? this.vehicleType,
      );
}

class VehicleInfoNotifier extends Notifier<VehicleInfoState> {
  @override
  VehicleInfoState build() => const VehicleInfoState();

  void setVehicleType(VehicleType type) =>
      state = state.copyWith(vehicleType: type, error: null);

  Future<bool> submit({
    required String driverId,
    required String make,
    required String model,
    required int year,
    required String color,
    required String plateNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(onboardingRepositoryProvider).saveVehicle(
          driverId: driverId,
          make: make,
          model: model,
          year: year,
          color: color,
          plateNumber: plateNumber,
          vehicleType: state.vehicleType,
        );
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
      (v) {
        state = state.copyWith(isLoading: false, vehicle: v);
        return true;
      },
    );
  }
}

final vehicleInfoProvider =
    NotifierProvider<VehicleInfoNotifier, VehicleInfoState>(
        VehicleInfoNotifier.new);

// ── Document Upload ────────────────────────────────────────────

class DocumentUploadState {
  const DocumentUploadState({
    this.uploads = const {},
    this.uploadingType,
    this.error,
    this.submitted = false,
  });
  final Map<DocumentType, String> uploads; // type → fileUrl
  final DocumentType? uploadingType;
  final String? error;
  final bool submitted;

  bool get allUploaded =>
      DocumentType.values.every((t) => uploads.containsKey(t));

  DocumentUploadState copyWith({
    Map<DocumentType, String>? uploads,
    DocumentType? uploadingType,
    String? error,
    bool? submitted,
  }) =>
      DocumentUploadState(
        uploads: uploads ?? this.uploads,
        uploadingType: uploadingType,
        error: error,
        submitted: submitted ?? this.submitted,
      );
}

class DocumentUploadNotifier extends Notifier<DocumentUploadState> {
  @override
  DocumentUploadState build() => const DocumentUploadState();

  Future<bool> uploadDocument({
    required String driverId,
    required DocumentType documentType,
    required dynamic file,
  }) async {
    state = state.copyWith(uploadingType: documentType, error: null);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repo = ref.read(onboardingRepositoryProvider);

    final uploadResult = await repo.uploadDocument(
      userId: userId,
      documentType: documentType,
      file: file,
    );

    return uploadResult.fold(
      (f) {
        state = state.copyWith(uploadingType: null, error: f.message);
        return false;
      },
      (url) async {
        final saveResult = await repo.saveDocument(
          driverId: driverId,
          documentType: documentType,
          fileUrl: url,
        );
        return saveResult.fold(
          (f) {
            state = state.copyWith(uploadingType: null, error: f.message);
            return false;
          },
          (_) {
            final updated = Map<DocumentType, String>.from(state.uploads)
              ..[documentType] = url;
            state = state.copyWith(uploads: updated, uploadingType: null);
            return true;
          },
        );
      },
    );
  }

  Future<bool> submitForReview(String driverId) async {
    state = state.copyWith(error: null);
    final result =
        await ref.read(onboardingRepositoryProvider).submitForReview(driverId);
    return result.fold(
      (f) {
        state = state.copyWith(error: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(submitted: true);
        return true;
      },
    );
  }

  Future<void> loadExisting(String driverId) async {
    final result =
        await ref.read(onboardingRepositoryProvider).getDocuments(driverId);
    result.fold(
      (_) => null,
      (docs) {
        final map = {for (final d in docs) d.documentType: d.fileUrl};
        state = state.copyWith(uploads: map);
      },
    );
  }
}

final documentUploadProvider =
    NotifierProvider<DocumentUploadNotifier, DocumentUploadState>(
        DocumentUploadNotifier.new);
