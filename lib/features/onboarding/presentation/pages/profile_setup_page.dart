import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/inputs/namaa_text_field.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../providers/onboarding_provider.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (file != null) {
      ref.read(profileSetupProvider.notifier).setAvatarFile(file);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(profileSetupProvider.notifier).submit(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        );
    if (success && mounted) {
      context.go(RouteNames.vehicleInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);

    return Scaffold(
      appBar: const NamaaAppBar(title: 'إعداد الملف الشخصي', showBack: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NamaaSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(current: 1, total: 3),
                const SizedBox(height: NamaaSpacing.lg),
                Text('معلوماتك الشخصية', style: NamaaTypography.heading1),
                const SizedBox(height: NamaaSpacing.sm),
                Text(
                  'أدخل بياناتك الأساسية لإنشاء حسابك',
                  style: NamaaTypography.bodyMedium
                      .copyWith(color: NamaaColors.textSecondary),
                ),
                const SizedBox(height: NamaaSpacing.xl),
                Center(child: _AvatarPicker(state: state, onTap: _pickAvatar)),
                const SizedBox(height: NamaaSpacing.xl),
                NamaaTextField(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: NamaaSpacing.md),
                NamaaTextField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني (اختياري)',
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                if (state.error != null) ...[
                  const SizedBox(height: NamaaSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(NamaaSpacing.md),
                    decoration: BoxDecoration(
                      color: NamaaColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: NamaaColors.error, size: 20),
                        const SizedBox(width: NamaaSpacing.sm),
                        Expanded(
                          child: Text(state.error!,
                              style: NamaaTypography.bodySmall
                                  .copyWith(color: NamaaColors.error)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: NamaaSpacing.xl),
                PrimaryButton(
                  label: 'التالي — معلومات المركبة',
                  onPressed: state.isLoading ? null : _submit,
                  isLoading: state.isLoading,
                  icon: Icons.arrow_forward,
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

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.state, required this.onTap});
  final ProfileSetupState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: NamaaColors.primaryLight,
            backgroundImage:
                state.avatarFile != null ? _imageProvider(state.avatarFile) : null,
            child: state.avatarFile == null
                ? const Icon(Icons.person, size: 52, color: NamaaColors.primaryDark)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NamaaColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt,
                  size: 18, color: NamaaColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _imageProvider(dynamic file) {
    try {
      // XFile on mobile/web
      final path = (file as dynamic).path as String;
      if (path.startsWith('blob:') || path.startsWith('http')) {
        return NetworkImage(path);
      }
      return NetworkImage(path);
    } catch (_) {
      return null;
    }
  }
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
