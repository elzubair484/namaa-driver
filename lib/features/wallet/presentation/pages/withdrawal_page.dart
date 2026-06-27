import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../providers/wallet_provider.dart';

class WithdrawalPage extends ConsumerStatefulWidget {
  const WithdrawalPage({super.key});

  @override
  ConsumerState<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends ConsumerState<WithdrawalPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _bankCtrl.dispose();
    _accountCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final wallet = ref.read(walletProvider).valueOrNull;

    if (wallet == null) return;
    if (amount > wallet.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المبلغ أكبر من رصيدك المتاح')),
      );
      return;
    }

    final result = await ref.read(withdrawalNotifierProvider.notifier).request(
          amount: amount,
          bankName: _bankCtrl.text.trim(),
          accountNumber: _accountCtrl.text.trim(),
          accountName: _nameCtrl.text.trim(),
        );

    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم إرسال طلب السحب بنجاح'),
            backgroundColor: NamaaColors.onlineGreen),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider).valueOrNull;
    final isLoading = ref.watch(withdrawalNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'طلب سحب'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NamaaSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance summary
              Container(
                padding: const EdgeInsets.all(NamaaSpacing.md),
                decoration: BoxDecoration(
                  color: NamaaColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الرصيد المتاح للسحب',
                        style: NamaaTypography.bodyMedium),
                    Text(
                      '${wallet?.availableBalance.toStringAsFixed(2) ?? '٠'} ج.س',
                      style: NamaaTypography.heading3
                          .copyWith(color: NamaaColors.primaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NamaaSpacing.lg),

              _Field(
                controller: _amountCtrl,
                label: 'المبلغ (ج.س)',
                inputType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'أدخل المبلغ';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'مبلغ غير صالح';
                  return null;
                },
              ),
              const SizedBox(height: NamaaSpacing.md),
              _Field(
                controller: _bankCtrl,
                label: 'اسم البنك',
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'أدخل اسم البنك' : null,
              ),
              const SizedBox(height: NamaaSpacing.md),
              _Field(
                controller: _accountCtrl,
                label: 'رقم الحساب / IBAN',
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'أدخل رقم الحساب' : null,
              ),
              const SizedBox(height: NamaaSpacing.md),
              _Field(
                controller: _nameCtrl,
                label: 'اسم صاحب الحساب',
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'أدخل اسم صاحب الحساب' : null,
              ),
              const SizedBox(height: NamaaSpacing.lg),
              Container(
                padding: const EdgeInsets.all(NamaaSpacing.md),
                decoration: BoxDecoration(
                  color: NamaaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NamaaColors.divider),
                ),
                child: Text(
                  '⚠️ يتم معالجة طلبات السحب خلال 1-3 أيام عمل. سيتم خصم المبلغ من رصيدك فور إرسال الطلب.',
                  style: NamaaTypography.bodySmall
                      .copyWith(color: NamaaColors.textSecondary),
                ),
              ),
              const SizedBox(height: NamaaSpacing.lg),
              PrimaryButton(
                label: 'إرسال طلب السحب',
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.inputType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? inputType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: NamaaColors.surface,
      ),
    );
  }
}
