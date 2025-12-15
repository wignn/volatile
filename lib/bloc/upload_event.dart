abstract class UploadEvent {}

class SelectFile extends UploadEvent {}

class UploadFile extends UploadEvent {
  final String filePath;
  final String fileName;
  final int? folderId;
  final List<int>? categoryIds;

  UploadFile({
    required this.filePath,
    required this.fileName,
    this.folderId,
    this.categoryIds,
  });
}

class ResetUpload extends UploadEvent {}
