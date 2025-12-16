import 'package:vasvault/constants/app_constant.dart';
import 'package:vasvault/models/storage_summary.dart';

class WorkspaceFile {
  final int id;
  final int userId;
  final int workspaceId;
  final String fileName;
  final String filePath;
  final int size;
  final String mimeType;
  final DateTime createdAt;

  WorkspaceFile({
    required this.id,
    required this.userId,
    required this.workspaceId,
    required this.fileName,
    required this.filePath,
    required this.size,
    required this.mimeType,
    required this.createdAt,
  });

  factory WorkspaceFile.fromJson(Map<String, dynamic> json) {
    return WorkspaceFile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      workspaceId: json['workspace_id'] ?? 0,
      fileName: json['file_name'] ?? json['filename'] ?? 'Tanpa Nama',
      filePath: json['file_path'] ?? json['file_url'] ?? '',
      size: json['size'] ?? 0,
      mimeType: json['mime_type'] ?? 'unknown',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Check if file is an image
  bool get isImage {
    return mimeType.startsWith('image/');
  }

  /// Check if file is a PDF
  bool get isPdf => mimeType.contains('pdf');

  /// Get full download URL for the file
  String get fullDownloadUrl {
    final baseUrl = AppConstants.baseUrl;
    if (filePath.startsWith('http')) return filePath;
    // Replace backslash with forward slash for URL
    final normalizedPath = filePath.replaceAll('\\', '/');
    return '$baseUrl/$normalizedPath';
  }

  /// Get thumbnail URL (same as download URL for images)
  String get thumbnailUrl => fullDownloadUrl;

  /// Get file URL for download/preview
  String get fileUrl => '${AppConstants.baseUrl}/api/v1/files/$id/download';

  /// Get file type label for display
  String get fileTypeLabel {
    if (mimeType.startsWith('image/')) return 'Image';
    if (mimeType.startsWith('video/')) return 'Video';
    if (mimeType.startsWith('audio/')) return 'Audio';
    if (mimeType.contains('pdf')) return 'PDF';
    if (mimeType.contains('word') || mimeType.contains('document'))
      return 'DOC';
    if (mimeType.contains('sheet') || mimeType.contains('excel')) return 'XLS';
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint'))
      return 'PPT';
    if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('tar'))
      return 'ZIP';
    return 'File';
  }

  /// Convert to LatestFile for compatibility with FileViewerPage
  LatestFile toLatestFile() {
    return LatestFile(
      id: id,
      userId: userId,
      folderId: null,
      fileName: fileName,
      filePath: filePath,
      mimeType: mimeType,
      size: size,
      createdAt: createdAt,
    );
  }
}
