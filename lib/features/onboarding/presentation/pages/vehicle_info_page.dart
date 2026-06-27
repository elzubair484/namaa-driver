import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/radius.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/buttons/secondary_button.dart';
import '../../../../design_system/components/inputs/namaa_text_field.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/onboarding_provider.dart';

class VehicleInfoPage extends ConsumerStatefulWidget {
  const VehicleInfoPage({super.key});

  @override
  ConsumerState<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends ConsumerState<VehicleInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final driver = ref.read(currentDriverProvider).value;
    if (driver == null) return;

    final success = await ref.read(vehicleInfoProvider.notifier).submit(
          driverId: driver.id,
          make: _makeCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.parse(_yearCtrl.text.trim()),
          color: _colorCtrl.text.trim(),
          plateNumber: _plateCtrl.text.trim(),
        );

    if (success && mounted) {
      context.go(RouteNames.documentUpload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleInfoProvider);

    return Scaffold(
      appBar: const NamaaAppBar(title: 'معلومات المركبة'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(current: 2, total: 3),
                const SizedBox(height: NamaaSpacing.lg),
                Text('بيانات مركبتك', style: NamaaTypography.heading1),
                const SizedBox(height: NamaaSpacing.sm),
                Text(
                  'أدخل معلومات المركبة التي ستستخدمها في التنقلات',
                  style: NamaaTypography.bodyMedium
                      .copyWith(color: NamaaColors.textSecondary),
                ),
                const SizedBox(height: NamaaSpacing.xl),
                Text('نوع المركبة', style: NamaaTypography.labelMedium),
                const SizedBox(height: NamaaSpacing.sm),
                _VehicleTypePicker(
                  selected: state.vehicleType,
                  onChanged: (t) =>
                      ref.read(vehicleInfoProvider.notifier).setVehicleType(t),
                ),
                const SizedBox(height: NamaaSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: NamaaTextField(
                        controller: _makeCtrl,
                        label: 'الماركة',
                        hint: 'مثال: تويوتا',
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: NamaaSpacing.md),
                    Expanded(
                      child: NamaaTextField(
                        controller: _modelCtrl,
                        label: 'الموديل',
                        hint: 'مثال: كامري',
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NamaaSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: NamaaTextField(
                        controller: _yearCtrl,
                        label: 'سنة الصنع',
                        hint: '${DateTime.now().year}',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 4,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: NamaaSpacing.md),
                    Expanded(
                      child: NamaaTextField(
                        controller: _colorCtrl,
                        label: 'اللون',
                        hint: 'مثال: أبيض',
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NamaaSpacing.md),
                NamaaTextField(
                  controller: _plateCtrl,
                  label: 'رقم اللوحة',
                  hint: 'أدخل رقم لوحة المركبة',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: NamaaSpacing.md),
                  _ErrorBox(message: state.error!),
                ],
                const SizedBox(height: NamaaSpacing.xl),
                PrimaryButton(
                  label: 'التالي — رفع الوثائق',
                  onPressed: state.isLoading ? null : _submit,
                  isLoading: state.isLoading,
                  icon: Icons.arrow_forward,
                ),
                const SizedBox(height: NamaaSpacing.sm),
                SecondaryButton(
                  label: 'رجوع',
                  onPressed: () => context.pop(),
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

class _VehicleTypePicker extends StatelessWidget {
  const _VehicleTypePicker({required this.selected, required this.onChanged});
  final VehicleType selected;
  final ValueChanged<VehicleType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: VehicleType.values.map((type) {
        final isSelected = type == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: Container(
              margin: EdgeInsets.only(
                  left: type == VehicleType.values.first ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? NamaaColors.primary : NamaaColors.surface,
                borderRadius: NamaaRadius.mdAll,
                border: Border.all(
                  color: isSelected ? NamaaColors.primary : NamaaColors.divider,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _icon(type),
                    color: isSelected
                        ? NamaaColors.onPrimary
                        : NamaaColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _label(type),
                    style: NamaaTypography.labelSmall.copyWith(
                      color: isSelected
                          ? NamaaColors.onPrimary
                          : NamaaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _icon(VehicleType t) => switch (t) {
        VehicleType.economy => Icons.directions_car,
        VehicleType.comfort => Icons.airline_seat_recline_extra,
        VehicleType.suv => Icons.directions_car_filled,
      };

  String _label(VehicleType t) => switch (t) {
        VehicleType.economy => 'اقتصادي',
        VehicleType.comfort => 'مريح',
        VehicleType.suv => 'SUV',
      };
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        final done = i + 1 < current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
            height: 4,
            decoration: BoxDecoration(
              color: done || active ? NamaaColors.primary : NamaaColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NamaaSpacing.md),
      decoration: BoxDecoration(
        color: NamaaColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: NamaaColors.error, size: 20),
          const SizedBox(width: NamaaSpacing.sm),
          Expanded(
            child: Text(message,
                style: NamaaTypography.bodySmall
                    .copyWith(color: NamaaColors.error)),
          ),
        ],
      ),
    );
  }
}
