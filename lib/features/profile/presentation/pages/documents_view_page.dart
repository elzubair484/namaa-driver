import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/components/misc/namaa_app_bar.dart';
import '../../../../design_system/components/feedback/loading_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/domain/entities/document_entity.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class DocumentsViewPage extends ConsumerStatefulWidget {
  const DocumentsViewPage({super.key});

  @override
  ConsumerState<DocumentsViewPage> createState() => _DocumentsViewPageState();
}

class _DocumentsViewPageState extends ConsumerState<DocumentsViewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final driver = ref.read(currentDriverProvider).valueOrNull;
      if (driver != null) {
        ref.read(documentUploadProvider.notifier).loadExisting(driver.id);
      }
    });
  }

  Future<void> _pickAndUpload(DocumentType type) async {
    final driver = ref.read(currentDriverProvider).valueOrNull;
    if (driver == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (file == null || !mounted) return;
    await ref.read(documentUploadProvider.notifier).uploadDocument(
          driverId: driver.id,
          documentType: type,
          file: file,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentUploadProvider);

    return Scaffold(
      backgroundColor: NamaaColors.background,
      appBar: const NamaaAppBar(title: 'المستندات'),
      body: state.uploadingType != null && state.uploads.isEmpty
          ? const LoadingState()
          : ListView(
              padding: const EdgeInsets.all(NamaaSpacing.md),
              children: DocumentType.values.map((type) {
                final url = state.uploads[type];
                final isUploaded = url != null;
                final isUploading = state.uploadingType == type;

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: NamaaSpacing.sm),
                  padding: const EdgeInsets.all(NamaaSpacing.md),
                  decoration: BoxDecoration(
                    color: NamaaColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUploaded
                          ? NamaaColors.onlineGreen
                          : NamaaColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(NamaaSpacing.sm),
                        decoration: BoxDecoration(
                          color: isUploaded
                              ? NamaaColors.onlineGreen.withValues(alpha: 0.1)
                              : NamaaColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUploaded
                              ? Icons.check_circle
                              : Icons.upload_file,
                          color: isUploaded
                              ? NamaaColors.onlineGreen
                              : NamaaColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: NamaaSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type.labelAr,
                                style: NamaaTypography.labelMedium),
                            Text(
                              isUploaded ? 'تم الرفع' : 'لم يُرفع بعد',
                              style: NamaaTypography.caption.copyWith(
                                  color: isUploaded
                                      ? NamaaColors.onlineGreen
                                      : NamaaColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (isUploading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      else
                        TextButton(
                          onPressed: () => _pickAndUpload(type),
                          child: Text(
                            isUploaded ? 'تغيير' : 'رفع',
                            style: NamaaTypography.labelMedium.copyWith(
                                color: NamaaColors.primaryDark),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
