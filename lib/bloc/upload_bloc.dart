import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/upload_event.dart';
import 'package:vasvault/bloc/upload_state.dart';
import 'package:vasvault/services/api.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final ApiService _apiService;

  UploadBloc({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(UploadInitial()) {
    on<SelectFile>(_onSelectFile);
    on<UploadFile>(_onUploadFile);
    on<ResetUpload>(_onResetUpload);
  }

  Future<void> _onSelectFile(
    SelectFile event,
    Emitter<UploadState> emit,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          emit(
            FileSelected(
              filePath: file.path!,
              fileName: file.name,
              fileSize: file.size,
            ),
          );
        }
      }
    } catch (e) {
      emit(UploadError('Gagal memilih file: $e'));
    }
  }

  Future<void> _onUploadFile(
    UploadFile event,
    Emitter<UploadState> emit,
  ) async {
    try {
      emit(UploadInProgress(fileName: event.fileName, progress: 0));

      final response = await _apiService.uploadFile(
        filePath: event.filePath,
        fileName: event.fileName,
        folderId: event.folderId,
        categoryIds: event.categoryIds,
        onProgress: (sent, total) {
          final progress = total > 0 ? sent / total : 0.0;
          emit(UploadInProgress(fileName: event.fileName, progress: progress));
        },
      );

      emit(UploadSuccess(response));
    } catch (e) {
      String message = 'Gagal mengupload file';
      if (e is DioException) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'].toString() ?? message;
        }
      } else if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }
      emit(UploadError(message));
    }
  }

  void _onResetUpload(ResetUpload event, Emitter<UploadState> emit) {
    emit(UploadInitial());
  }
}
