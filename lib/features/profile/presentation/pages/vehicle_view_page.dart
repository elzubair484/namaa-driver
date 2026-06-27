import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/domain/entities/vehicle_entity.dart';

class VehicleViewPage extends ConsumerStatefulWidget {
  const VehicleViewPage({super.key});

  @override
  ConsumerState<VehicleViewPage> createState() => _VehicleViewPageState();
}

class _VehicleViewPageState extends ConsumerState<VehicleViewPage> {
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;
    try {
      final data = await Supabase.instance.client
          .from('driver_vehicles')
          .select()
          .eq('driver_id', driver.id)
          .maybeSingle();
      if (data != null && mounted) {
        _makeCtrl.text = data['make'] as String? ?? '';
        _modelCtrl.text = data['model'] as String? ?? '';
        _yearCtrl.text = (data['year'] as int?)?.toString() ?? '';
        _colorCtrl.text = data['color'] as String? ?? '';
        _plateCtrl.text = data['plate_number'] as String? ?? '';
        final typeStr = data['vehicle_type'] as String?;
        final vt = VehicleType.values.firstWhere(
          (v) => v.name == typeStr,
          orElse: () => VehicleType.economy,
        );
        ref.read(vehicleInfoProvider.notifier).setVehicleType(vt);
        setState(() => _initialized = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleInfoProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'معلومات المركبة'),
      body: state.isLoading
          ? const LoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vehicle type selector
                  Text('نوع المركبة', style: NamaaTypography.heading3),
                  const SizedBox(height: NamaaSpacing.sm),
                  Row(
                    children: VehicleType.values.map((t) {
                      final selected = state.vehicleType == t;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: NamaaSpacing.sm),
                          child: GestureDetector(
                            onTap: () => ref
                                .read(vehicleInfoProvider.notifier)
                                .setVehicleType(t),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(NamaaSpacing.sm),
                              decoration: BoxDecoration(
                                color: selected
                                    ? NamaaColors.primaryLight
                                    : NamaaColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? NamaaColors.primary
                                      : NamaaColors.divider,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(_vehicleIcon(t),
                                      color: selected
                                          ? NamaaColors.primaryDark
                                          : NamaaColors.textSecondary),
                                  Text(_vehicleLabel(t),
                                      style: NamaaTypography.caption.copyWith(
                                          color: selected
                                              ? NamaaColors.primaryDark
                                              : NamaaColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: NamaaSpacing.md),
                  _Field(ctrl: _makeCtrl, label: 'الشركة المصنعة'),
                  const SizedBox(height: NamaaSpacing.md),
                  _Field(ctrl: _modelCtrl, label: 'الموديل'),
                  const SizedBox(height: NamaaSpacing.md),
                  _Field(
                      ctrl: _yearCtrl,
                      label: 'سنة الصنع',
                      inputType: TextInputType.number),
                  const SizedBox(height: NamaaSpacing.md),
                  _Field(ctrl: _colorCtrl, label: 'اللون'),
                  const SizedBox(height: NamaaSpacing.md),
                  _Field(ctrl: _plateCtrl, label: 'رقم اللوحة'),
                  const SizedBox(height: NamaaSpacing.lg),
                  if (state.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(NamaaSpacing.md),
                      decoration: BoxDecoration(
                        color: NamaaColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(state.error!,
                          style: NamaaTypography.bodySmall
                              .copyWith(color: NamaaColors.error)),
                    ),
                    const SizedBox(height: NamaaSpacing.md),
                  ],
                  PrimaryButton(
                    label: 'حفظ التغييرات',
                    isLoading: state.isLoading,
                    onPressed: () async {
                      final driver =
                          ref.read(currentDriverProvider).valueOrNull;
                      if (driver == null) return;
                      final success = await ref
                          .read(vehicleInfoProvider.notifier)
                          .submit(
                            driverId: driver.id,
                            make: _makeCtrl.text.trim(),
                            model: _modelCtrl.text.trim(),
                            year: int.tryParse(_yearCtrl.text.trim()) ?? 0,
                            color: _colorCtrl.text.trim(),
                            plateNumber: _plateCtrl.text.trim(),
                          );
                      if (!mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديث معلومات المركبة'),
                            backgroundColor: NamaaColors.onlineGreen,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  IconData _vehicleIcon(VehicleType t) => switch (t) {
        VehicleType.economy => Icons.directions_car,
        VehicleType.comfort => Icons.airline_seat_recline_extra,
        VehicleType.suv => Icons.directions_car_filled,
      };

  String _vehicleLabel(VehicleType t) => switch (t) {
        VehicleType.economy => 'اقتصادية',
        VehicleType.comfort => 'مريحة',
        VehicleType.suv => 'دفع رباعي',
      };
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.ctrl,
      required this.label,
      this.inputType});
  final TextEditingController ctrl;
  final String label;
  final TextInputType? inputType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: NamaaColors.surface,
      ),
    );
  }
}
