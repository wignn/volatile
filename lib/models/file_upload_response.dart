class FileUploadResponse {
  final int id;
  final String fileName;
  final String filePath;
  final int size;

  FileUploadResponse({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.size,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      id: json['id'] as int,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'size': size,
    };
  }
}
