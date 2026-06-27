import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/inputs/otp_field.dart';
import '../providers/auth_provider.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _otpController = TextEditingController();
  String _otp = '';
  int _resendCooldown = AppConfig.otpResendCooldownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 0) {
        t.cancel();
        return;
      }
      if (mounted) setState(() => _resendCooldown--);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    final success = await ref
        .read(verifyOtpProvider.notifier)
        .verify(phone: widget.phone, otp: _otp);

    if (!mounted) return;
    if (success) {
      // Router redirect will send to home or onboarding based on driver status
      context.go(RouteNames.home);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    await ref.read(sendOtpProvider.notifier).send(widget.phone);
    setState(() => _resendCooldown = AppConfig.otpResendCooldownSeconds);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyOtpProvider);
    final isLoading = state.isLoading;
    final error = state.hasError ? state.error.toString() : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: NamaaSpacing.xl),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: NamaaSpacing.lg),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NamaaColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: NamaaColors.primaryDark,
                  size: 28,
                ),
              ),
              const SizedBox(height: NamaaSpacing.lg),
              Text('أدخل رمز التحقق', style: NamaaTypography.displayMedium),
              const SizedBox(height: NamaaSpacing.sm),
              Text(
                'تم إرسال رمز مكون من 6 أرقام إلى\n${widget.phone.maskedPhone}',
                style: NamaaTypography.bodyLarge.copyWith(
                  color: NamaaColors.textSecondary,
                ),
              ),
              const SizedBox(height: NamaaSpacing.xl),
              OtpField(
                controller: _otpController,
                onCompleted: (v) {
                  setState(() => _otp = v);
                  _verify();
                },
                onChanged: (v) => setState(() => _otp = v),
              ),
              if (error != null) ...[
                const SizedBox(height: NamaaSpacing.sm),
                Text(
                  error,
                  style: NamaaTypography.bodySmall.copyWith(
                    color: NamaaColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: NamaaSpacing.lg),
              Center(
                child: _resendCooldown > 0
                    ? Text(
                        'إعادة الإرسال بعد $_resendCooldown ثانية',
                        style: NamaaTypography.bodySmall.copyWith(
                          color: NamaaColors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('إعادة إرسال الرمز'),
                      ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'تحقق',
                onPressed: _otp.length == 6 && !isLoading ? _verify : null,
                isLoading: isLoading,
              ),
              const SizedBox(height: NamaaSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
