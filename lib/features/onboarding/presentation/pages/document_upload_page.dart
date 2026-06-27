import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/route_names.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/radius.dart';
import '../../../../design_system/components/buttons/primary_button.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/document_entity.dart';
import '../providers/onboarding_provider.dart';

class DocumentUploadPage extends ConsumerStatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  ConsumerState<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends ConsumerState<DocumentUploadPage> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  Future<void> _loadExisting() async {
    final driver = ref.read(currentDriverProvider).value;
    if (driver != null) {
      await ref
          .read(documentUploadProvider.notifier)
          .loadExisting(driver.id);
    }
  }

  Future<void> _pickDocument(DocumentType type) async {
    final driver = ref.read(currentDriverProvider).value;
    if (driver == null) return;

    final choice = await _showSourceDialog();
    if (choice == null) return;

    final file = await _picker.pickImage(
      source: choice,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (file == null) return;

    await ref.read(documentUploadProvider.notifier).uploadDocument(
          driverId: driver.id,
          documentType: type,
          file: file,
        );
  }

  Future<ImageSource?> _showSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NamaaSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: NamaaSpacing.md),
                decoration: BoxDecoration(
                  color: NamaaColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('اختر المصدر', style: NamaaTypography.heading3),
              const SizedBox(height: NamaaSpacing.md),
              _SourceTile(
                icon: Icons.camera_alt,
                label: 'الكاميرا',
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: NamaaSpacing.sm),
              _SourceTile(
                icon: Icons.photo_library,
                label: 'معرض الصور',
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: NamaaSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForReview() async {
    final driver = ref.read(currentDriverProvider).value;
    if (driver == null) return;

    final success = await ref
        .read(documentUploadProvider.notifier)
        .submitForReview(driver.id);

    if (success && mounted) {
      context.go(RouteNames.pendingApproval);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentUploadProvider);

    final requiredDocs = [
      DocumentType.nationalId,
      DocumentType.driversLicense,
      DocumentType.vehicleRegistration,
      DocumentType.insurance,
    ];
    final vehiclePhotos = [
      DocumentType.vehicleFront,
      DocumentType.vehicleBack,
      DocumentType.vehicleSide,
    ];

    return Scaffold(
      appBar: const NamaaAppBar(title: 'رفع الوثائق'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NamaaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(current: 3, total: 3),
                    const SizedBox(height: NamaaSpacing.lg),
                    Text('وثائق مطلوبة', style: NamaaTypography.heading1),
                    const SizedBox(height: NamaaSpacing.xs),
                    Text(
                      'يرجى رفع جميع الوثائق المطلوبة بصورة واضحة',
                      style: NamaaTypography.bodyMedium
                          .copyWith(color: NamaaColors.textSecondary),
                    ),
                    const SizedBox(height: NamaaSpacing.md),
                    _SectionLabel(label: 'وثائق السائق'),
                    const SizedBox(height: NamaaSpacing.sm),
                    ...requiredDocs.map((type) => _DocumentTile(
                          type: type,
                          isUploaded: state.uploads.containsKey(type),
                          isUploading: state.uploadingType == type,
                          onTap: () => _pickDocument(type),
                        )),
                    const SizedBox(height: NamaaSpacing.md),
                    _SectionLabel(label: 'صور المركبة'),
                    const SizedBox(height: NamaaSpacing.sm),
                    ...vehiclePhotos.map((type) => _DocumentTile(
                          type: type,
                          isUploaded: state.uploads.containsKey(type),
                          isUploading: state.uploadingType == type,
                          onTap: () => _pickDocument(type),
                        )),
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
                              child: Text(
                                state.error!,
                                style: NamaaTypography.bodySmall
                                    .copyWith(color: NamaaColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: NamaaSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NamaaSpacing.md,
                0,
                NamaaSpacing.md,
                NamaaSpacing.md,
              ),
              child: Column(
                children: [
                  _UploadProgressBar(
                    uploaded: state.uploads.length,
                    total: DocumentType.values.length,
                  ),
                  const SizedBox(height: NamaaSpacing.md),
                  PrimaryButton(
                    label: state.allUploaded
                        ? 'إرسال للمراجعة'
                        : 'أكمل رفع الوثائق (${state.uploads.length}/${DocumentType.values.length})',
                    onPressed: state.allUploaded &&
                            state.uploadingType == null
                        ? _submitForReview
                        : null,
                    icon: state.allUploaded ? Icons.check_circle : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.type,
    required this.isUploaded,
    required this.isUploading,
    required this.onTap,
  });
  final DocumentType type;
  final bool isUploaded;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: NamaaSpacing.sm),
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: isUploaded
              ? NamaaColors.success.withValues(alpha: 0.06)
              : NamaaColors.surface,
          borderRadius: NamaaRadius.mdAll,
          border: Border.all(
            color: isUploaded ? NamaaColors.success : NamaaColors.divider,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUploaded
                    ? NamaaColors.success.withValues(alpha: 0.12)
                    : NamaaColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: NamaaColors.primary),
                    )
                  : Icon(
                      isUploaded ? Icons.check_circle : _icon(type),
                      color: isUploaded
                          ? NamaaColors.success
                          : NamaaColors.primaryDark,
                      size: 22,
                    ),
            ),
            const SizedBox(width: NamaaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.labelAr, style: NamaaTypography.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    isUploading
                        ? 'جارٍ الرفع...'
                        : isUploaded
                            ? 'تم الرفع بنجاح'
                            : 'اضغط لرفع الصورة',
                    style: NamaaTypography.bodySmall.copyWith(
                      color: isUploaded
                          ? NamaaColors.success
                          : NamaaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.edit_outlined : Icons.upload_outlined,
              color: isUploaded ? NamaaColors.success : NamaaColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(DocumentType t) => switch (t) {
        DocumentType.nationalId => Icons.badge,
        DocumentType.driversLicense => Icons.card_membership,
        DocumentType.vehicleRegistration => Icons.description,
        DocumentType.insurance => Icons.shield,
        DocumentType.vehicleFront => Icons.directions_car,
        DocumentType.vehicleBack => Icons.directions_car_filled,
        DocumentType.vehicleSide => Icons.time_to_leave,
      };
}

class _UploadProgressBar extends StatelessWidget {
  const _UploadProgressBar({required this.uploaded, required this.total});
  final int uploaded;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : uploaded / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('التقدم', style: NamaaTypography.labelSmall),
            Text(
              '$uploaded / $total وثيقة',
              style: NamaaTypography.labelSmall
                  .copyWith(color: NamaaColors.primary),
            ),
          ],
        ),
        const SizedBox(height: NamaaSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: NamaaColors.divider,
            color: progress == 1.0 ? NamaaColors.success : NamaaColors.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: NamaaColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: NamaaSpacing.sm),
        Text(label, style: NamaaTypography.heading3),
      ],
    );
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

class _SourceTile extends StatelessWidget {
  const _SourceTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(NamaaSpacing.md),
        decoration: BoxDecoration(
          color: NamaaColors.surface,
          borderRadius: NamaaRadius.mdAll,
        ),
        child: Row(
          children: [
            Icon(icon, color: NamaaColors.primary),
            const SizedBox(width: NamaaSpacing.md),
            Text(label, style: NamaaTypography.labelMedium),
          ],
        ),
      ),
    );
  }
}
