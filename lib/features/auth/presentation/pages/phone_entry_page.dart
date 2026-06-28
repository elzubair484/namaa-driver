import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../providers/auth_provider.dart';

class PhoneEntryPage extends ConsumerStatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  ConsumerState<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends ConsumerState<PhoneEntryPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(signInProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInProvider);
    final isLoading = state.isLoading;
    final error = state.hasError ? state.error.toString() : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Form(
            key: _formKey,
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
                    Icons.directions_car,
                    color: NamaaColors.primaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: NamaaSpacing.lg),
                Text('مرحباً بك!', style: NamaaTypography.displayMedium),
                const SizedBox(height: NamaaSpacing.sm),
                Text(
                  'سجّل دخولك للمتابعة',
                  style: NamaaTypography.bodyLarge.copyWith(
                    color: NamaaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: NamaaSpacing.xl),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'أدخل بريداً إلكترونياً صحيحاً' : null,
                ),
                const SizedBox(height: NamaaSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'كلمة المرور قصيرة جداً' : null,
                ),
                if (error != null) ...[
                  const SizedBox(height: NamaaSpacing.sm),
                  Text(
                    error,
                    style: NamaaTypography.bodySmall
                        .copyWith(color: NamaaColors.error),
                  ),
                ],
                const SizedBox(height: NamaaSpacing.xxxl),
                PrimaryButton(
                  label: 'تسجيل الدخول',
                  onPressed: isLoading ? null : _signIn,
                  isLoading: isLoading,
                ),
                const SizedBox(height: NamaaSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
