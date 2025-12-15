import 'package:vasvault/models/file_upload_response.dart';

abstract class UploadState {}

class UploadInitial extends UploadState {}

class FileSelected extends UploadState {
  final String filePath;
  final String fileName;
  final int fileSize;

  FileSelected({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });
}

class UploadInProgress extends UploadState {
  final String fileName;
  final double progress;

  UploadInProgress({required this.fileName, required this.progress});
}

class UploadSuccess extends UploadState {
  final FileUploadResponse response;

  UploadSuccess(this.response);
}

class UploadError extends UploadState {
  final String message;

  UploadError(this.message);
}
