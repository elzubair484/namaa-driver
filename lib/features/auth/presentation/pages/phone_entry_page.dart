import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/inputs/phone_field.dart';
import '../providers/auth_provider.dart';

class PhoneEntryPage extends ConsumerStatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  ConsumerState<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends ConsumerState<PhoneEntryPage> {
  final _controller = TextEditingController();
  String _fullPhone = '';
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _submitted = true);
    if (_fullPhone.isEmpty) return;

    await ref.read(sendOtpProvider.notifier).send(_fullPhone);
    final state = ref.read(sendOtpProvider);

    if (state.value?.sent == true && mounted) {
      context.push(
        '${RouteNames.otpVerification}?phone=${Uri.encodeComponent(_fullPhone)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendOtpProvider);
    final isLoading = state.value?.isLoading == true;
    final error = state.value?.error;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: NamaaSpacing.xxxl),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NamaaColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: NamaaColors.primaryDark,
                  size: 28,
                ),
              ),
              const SizedBox(height: NamaaSpacing.lg),
              Text('مرحباً بك!', style: NamaaTypography.displayMedium),
              const SizedBox(height: NamaaSpacing.sm),
              Text(
                'أدخل رقم هاتفك للمتابعة',
                style: NamaaTypography.bodyLarge.copyWith(
                  color: NamaaColors.textSecondary,
                ),
              ),
              const SizedBox(height: NamaaSpacing.xl),
              NamaaPhoneField(
                controller: _controller,
                label: 'رقم الهاتف',
                onChanged: (phone) => setState(() => _fullPhone = phone),
              ),
              if (error != null) ...[
                const SizedBox(height: NamaaSpacing.sm),
                Text(
                  error,
                  style: NamaaTypography.bodySmall.copyWith(
                    color: NamaaColors.error,
                  ),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'إرسال رمز التحقق',
                onPressed: isLoading ? null : _send,
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
