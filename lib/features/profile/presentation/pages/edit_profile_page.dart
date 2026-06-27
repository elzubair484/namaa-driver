import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/misc/avatar_widget.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _init(BuildContext context) {
    if (_initialized) return;
    _initialized = true;
    final driver = ref.read(currentDriverProvider).valueOrNull;
    _nameCtrl.text = driver?.fullName ?? '';
    _emailCtrl.text = driver?.email ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (file != null) {
      ref.read(editProfileProvider.notifier).pickAvatar(file);
    }
  }

  Future<void> _save() async {
    await ref.read(editProfileProvider.notifier).save(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty
              ? null
              : _emailCtrl.text.trim(),
        );
    if (!mounted) return;
    final state = ref.read(editProfileProvider);
    if (state.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملف الشخصي'),
          backgroundColor: NamaaColors.onlineGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _init(context);

    final driver = ref.watch(currentDriverProvider).valueOrNull;
    final state = ref.watch(editProfileProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'تعديل الملف الشخصي'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NamaaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    state.avatarFile != null
                        ? CircleAvatar(
                            radius: 52,
                            backgroundImage:
                                NetworkImage(state.avatarFile!.path),
                          )
                        : AvatarWidget(
                            name: driver?.fullName ?? 'السائق',
                            imageUrl: driver?.avatarUrl,
                            radius: 52,
                          ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(NamaaSpacing.sm),
                        decoration: const BoxDecoration(
                          color: NamaaColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: NamaaColors.onPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: NamaaSpacing.lg),

            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon:
                    const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: NamaaColors.surface,
              ),
            ),
            const SizedBox(height: NamaaSpacing.md),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني (اختياري)',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: NamaaColors.surface,
              ),
            ),

            if (state.error != null) ...[
              const SizedBox(height: NamaaSpacing.md),
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
            ],

            const SizedBox(height: NamaaSpacing.lg),

            PrimaryButton(
              label: 'حفظ التغييرات',
              isLoading: state.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
