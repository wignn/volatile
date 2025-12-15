import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vasvault/bloc/storage_bloc.dart';
import 'package:vasvault/bloc/storage_event.dart';
import 'package:vasvault/bloc/storage_state.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:vasvault/widgets/upload_bottom_sheet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StorageBloc _storageBloc;

  @override
  void initState() {
    super.initState();
    _storageBloc = StorageBloc();
    _storageBloc.add(LoadStorageSummary());
  }

  @override
  void dispose() {
    _storageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final formattedDate = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return BlocProvider.value(
      value: _storageBloc,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _storageBloc.add(RefreshStorageSummary());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'VasVault',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Storage Summary Card
                  BlocBuilder<StorageBloc, StorageState>(
                    builder: (context, state) {
                      if (state is StorageLoading) {
                        return _buildLoadingCard();
                      } else if (state is StorageLoaded) {
                        return _buildStorageCard(state.storageSummary, isDark);
                      } else if (state is StorageError) {
                        return _buildErrorCard(state.message, isDark);
                      }
                      return _buildLoadingCard();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(isDark),
                  const SizedBox(height: 24),

                  // Latest File Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'File Terakhir',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to vault/files
                        },
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<StorageBloc, StorageState>(
                    builder: (context, state) {
                      if (state is StorageLoaded) {
                        return _buildLatestFileCard(
                          state.storageSummary.latestFile,
                          isDark,
                        );
                      }
                      return _buildEmptyFileCard(isDark);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorCard(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _storageBloc.add(LoadStorageSummary());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(StorageSummary storage, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Storage',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  storage.formattedMaxBytes,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Used storage large display
          Text(
            storage.formattedUsedBytes,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: storage.usagePercentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // Used and Remaining row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Digunakan',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          storage.formattedUsedBytes,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tersisa',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          storage.formattedRemainingBytes,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        _buildQuickActionButton(
          icon: Icons.cloud_upload_outlined,
          label: 'Upload',
          color: AppColors.primary,
          isDark: isDark,
          onTap: () {
            UploadBottomSheet.show(
              context,
              onUploadComplete: () {
                _storageBloc.add(RefreshStorageSummary());
              },
            );
          },
        ),
        const SizedBox(width: 12),
        _buildQuickActionButton(
          icon: Icons.folder_outlined,
          label: 'Folder',
          color: AppColors.success,
          isDark: isDark,
          onTap: () {
            // Handle folders
          },
        ),
        const SizedBox(width: 12),
        _buildQuickActionButton(
          icon: Icons.share_outlined,
          label: 'Shared',
          color: AppColors.warning,
          isDark: isDark,
          onTap: () {
            // Handle shared
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestFileCard(LatestFile? file, bool isDark) {
    if (file == null) {
      return _buildEmptyFileCard(isDark);
    }

    final formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(file.createdAt);
    final formattedSize = StorageSummary.formatBytes(file.size);

    IconData fileIcon = Icons.insert_drive_file_outlined;
    Color iconColor = AppColors.primary;

    if (file.mimeType.startsWith('image/')) {
      fileIcon = Icons.image_outlined;
      iconColor = AppColors.success;
    } else if (file.mimeType.startsWith('video/')) {
      fileIcon = Icons.video_file_outlined;
      iconColor = AppColors.error;
    } else if (file.mimeType.startsWith('audio/')) {
      fileIcon = Icons.audio_file_outlined;
      iconColor = AppColors.warning;
    } else if (file.mimeType.contains('pdf')) {
      fileIcon = Icons.picture_as_pdf_outlined;
      iconColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(fileIcon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedSize • $formattedDate',
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
          Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada file',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + untuk menambah file pertama',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
