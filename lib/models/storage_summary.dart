class LatestFile {
  final int id;
  final int userId;
  final int? folderId;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int size;
  final DateTime createdAt;

  LatestFile({
    required this.id,
    required this.userId,
    this.folderId,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.size,
    required this.createdAt,
  });

  factory LatestFile.fromJson(Map<String, dynamic> json) {
    return LatestFile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      folderId: json['folder_id'] as int?,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      mimeType: json['mime_type'] as String,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'folder_id': folderId,
      'file_name': fileName,
      'file_path': filePath,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StorageSummary {
  final int maxBytes;
  final int usedBytes;
  final int remainingBytes;
  final LatestFile? latestFile;

  StorageSummary({
    required this.maxBytes,
    required this.usedBytes,
    required this.remainingBytes,
    this.latestFile,
  });

  factory StorageSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return StorageSummary(
      maxBytes: data['max_bytes'] as int,
      usedBytes: data['used_bytes'] as int,
      remainingBytes: data['remaining_bytes'] as int,
      latestFile: data['latest_file'] != null
          ? LatestFile.fromJson(data['latest_file'] as Map<String, dynamic>)
          : null,
    );
  }

  double get usagePercentage => maxBytes > 0 ? (usedBytes / maxBytes) * 100 : 0;

  String get formattedMaxBytes => formatBytes(maxBytes);
  String get formattedUsedBytes => formatBytes(usedBytes);
  String get formattedRemainingBytes => formatBytes(remainingBytes);

  static String formatBytes(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }
}
