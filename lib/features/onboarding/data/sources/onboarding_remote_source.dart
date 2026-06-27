import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../auth/data/models/driver_model.dart';
import '../models/vehicle_model.dart';
import '../models/document_model.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/vehicle_entity.dart';

class OnboardingRemoteSource {
  OnboardingRemoteSource(this._client);
  final SupabaseClient _client;

  // ── Driver profile ─────────────────────────────────────────

  Future<DriverModel> createDriverProfile({
    required String fullName,
    required String phone,
    String? email,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;
      final data = await _client
          .from(SupabaseConfig.driversTable)
          .upsert({
            'user_id': userId,
            'full_name': fullName,
            'phone': phone,
            if (email != null && email.isNotEmpty) 'email': email,
            'status': 'pending',
            'locale': 'ar',
          }, onConflict: 'user_id')
          .select()
          .single();
      return DriverModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<DriverModel> updateDriverProfile({
    required String driverId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
      final data = await _client
          .from(SupabaseConfig.driversTable)
          .update(updates)
          .eq('id', driverId)
          .select()
          .single();
      return DriverModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  // ── Avatar upload ──────────────────────────────────────────

  Future<String> uploadAvatar({
    required String userId,
    required dynamic file,
  }) async {
    try {
      final ext = _fileExtension(file);
      final path = '$userId/avatar.$ext';
      await _client.storage.from(SupabaseConfig.avatarsBucket).uploadBinary(
            path,
            await _readBytes(file),
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );
      return _client.storage
          .from(SupabaseConfig.avatarsBucket)
          .getPublicUrl(path);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Vehicle ────────────────────────────────────────────────

  Future<VehicleModel> saveVehicle({
    required String driverId,
    required String make,
    required String model,
    required int year,
    required String color,
    required String plateNumber,
    required VehicleType vehicleType,
  }) async {
    try {
      final data = await _client
          .from(SupabaseConfig.vehiclesTable)
          .upsert({
            'driver_id': driverId,
            'make': make,
            'model': model,
            'year': year,
            'color': color,
            'plate_number': plateNumber,
            'vehicle_type': vehicleType.name,
            'is_active': true,
          }, onConflict: 'driver_id')
          .select()
          .single();
      return VehicleModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  // ── Document upload ────────────────────────────────────────

  Future<String> uploadDocument({
    required String userId,
    required DocumentType documentType,
    required dynamic file,
  }) async {
    try {
      final ext = _fileExtension(file);
      final path = '$userId/${documentType.key}.$ext';
      await _client.storage
          .from(SupabaseConfig.documentsBucket)
          .uploadBinary(
            path,
            await _readBytes(file),
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );
      // Return signed URL valid for 1 year
      return await _client.storage
          .from(SupabaseConfig.documentsBucket)
          .createSignedUrl(path, 60 * 60 * 24 * 365);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<DocumentModel> saveDocument({
    required String driverId,
    required DocumentType documentType,
    required String fileUrl,
    DateTime? expiryDate,
  }) async {
    try {
      final data = await _client
          .from(SupabaseConfig.documentsTable)
          .upsert({
            'driver_id': driverId,
            'document_type': documentType.key,
            'file_url': fileUrl,
            'status': 'pending',
            if (expiryDate != null)
              'expiry_date': expiryDate.toIso8601String().split('T').first,
            'uploaded_at': DateTime.now().toIso8601String(),
          }, onConflict: 'driver_id,document_type')
          .select()
          .single();
      return DocumentModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<List<DocumentModel>> getDocuments(String driverId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.documentsTable)
          .select()
          .eq('driver_id', driverId);
      return (data as List)
          .map((d) => DocumentModel.fromJson(d as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Future<DriverModel> submitForReview(String driverId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.driversTable)
          .update({
            'status': 'under_review',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', driverId)
          .select()
          .single();
      return DriverModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  // ── Helpers ────────────────────────────────────────────────

  String _fileExtension(dynamic file) {
    if (file is String) {
      final parts = file.split('.');
      return parts.last.toLowerCase().replaceAll('jpg', 'jpeg');
    }
    // XFile from image_picker
    try {
      final path = (file as dynamic).path as String;
      final ext = path.split('.').last.toLowerCase();
      return ext == 'jpg' ? 'jpeg' : ext;
    } catch (_) {
      return 'jpeg';
    }
  }

  Future<Uint8List> _readBytes(dynamic file) async {
    try {
      final bytes = await (file as dynamic).readAsBytes();
      if (bytes is Uint8List) return bytes;
      return Uint8List.fromList(bytes as List<int>);
    } catch (_) {
      return Uint8List(0);
    }
  }
}
