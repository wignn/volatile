import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/upload_bloc.dart';
import 'package:vasvault/bloc/upload_event.dart';
import 'package:vasvault/bloc/upload_state.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/theme/app_colors.dart';

class UploadBottomSheet extends StatelessWidget {
  final VoidCallback? onUploadComplete;

  const UploadBottomSheet({super.key, this.onUploadComplete});

  static void show(BuildContext context, {VoidCallback? onUploadComplete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => UploadBloc(),
        child: UploadBottomSheet(onUploadComplete: onUploadComplete),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<UploadBloc, UploadState>(
            listener: (context, state) {
              if (state is UploadSuccess) {
                onUploadComplete?.call();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'File berhasil diupload: ${state.response.fileName}',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (state is UploadError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Upload File',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content based on state
                  if (state is UploadInitial)
                    _buildSelectFileUI(context, isDark),
                  if (state is FileSelected)
                    _buildFileSelectedUI(context, state, isDark),
                  if (state is UploadInProgress)
                    _buildUploadingUI(context, state, isDark),

                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectFileUI(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => context.read<UploadBloc>().add(SelectFile()),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap untuk memilih file',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mendukung semua jenis file',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectedUI(
    BuildContext context,
    FileSelected state,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.fileName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      StorageSummary.formatBytes(state.fileSize),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.read<UploadBloc>().add(ResetUpload()),
                icon: Icon(
                  Icons.close,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.read<UploadBloc>().add(SelectFile()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ganti File',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<UploadBloc>().add(
                    UploadFile(
                      filePath: state.filePath,
                      fileName: state.fileName,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadingUI(
    BuildContext context,
    UploadInProgress state,
    bool isDark,
  ) {
    final percentage = (state.progress * 100).toInt();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: state.progress,
                        strokeWidth: 6,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Mengupload...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.fileName,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
