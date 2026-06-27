import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/app_exception.dart';
import '../models/driver_model.dart';

class AuthRemoteSource {
  AuthRemoteSource(this._client);
  final SupabaseClient _client;

  Future<void> sendOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw OtpException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<DriverModel?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session == null) return null;

      return _fetchDriver(response.user!.id);
    } on AuthException catch (e) {
      throw OtpException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<DriverModel?> getCurrentDriver() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchDriver(user.id);
  }

  Future<DriverModel?> _fetchDriver(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.driversTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return DriverModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code);
    }
  }

  Stream<DriverModel?> watchCurrentDriver() {
    final user = _client.auth.currentUser;
    if (user == null) return Stream.value(null);

    return _client
        .from(SupabaseConfig.driversTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .map((rows) {
          if (rows.isEmpty) return null;
          return DriverModel.fromJson(rows.first);
        });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
