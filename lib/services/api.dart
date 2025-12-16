import 'package:dio/dio.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/file_item.dart';
import 'package:vasvault/models/file_upload_response.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/models/profile_response.dart';
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/services/dio_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = DioClient().dio;

  ApiService._internal();

  Future<AuthResponseModel> login(LoginRequestModel requestBody) async {
    final response = await _dio.post('/login', data: requestBody.toJson());
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> signUp(RegisterRequestModel requestBody) async {
    try {
      final response = await _dio.post(
        '/register',
        data: requestBody.toJson(),
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data);
      }

      final serverMessage = _extractErrorMessage(response);
      throw Exception(serverMessage);
    } on DioException catch (e) {
      throw Exception(_extractDioErrorMessage(e));
    }
  }

  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/refresh',
      data: {'refresh_token': refreshToken},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<ProfileResponse> getProfile() async {
    final response = await _dio.get('/me');
    return ProfileResponse.fromJson(response.data);
  }

  Future<ProfileResponse> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    final response = await _dio.put(
      '/profile',
      data: {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
      },
    );
    return ProfileResponse.fromJson(response.data);
  }

  Future<StorageSummary> getStorageSummary() async {
    final response = await _dio.get('/storage/summary');
    return StorageSummary.fromJson(response.data);
  }

  Future<FileUploadResponse> uploadFile({
    required String filePath,
    required String fileName,
    int? folderId,
    List<int>? categoryIds,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (categoryIds != null && categoryIds.isNotEmpty)
        'category_ids': categoryIds,
    });

    final response = await _dio.post(
      '/files',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      onSendProgress: onProgress,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'];
      return FileUploadResponse.fromJson(data);
    }

    throw Exception(_extractErrorMessage(response));
  }

  Future<List<FileItem>> getFiles() async {
    final response = await _dio.get('/files');

    if (response.data is Map) {
      final map = response.data as Map<String, dynamic>;
      final List<dynamic> data =
          map['files'] ?? map['data'] ?? map['items'] ?? [];
      return data.map((json) => FileItem.fromJson(json)).toList();
    } else if (response.data is List) {
      return (response.data as List)
          .map((json) => FileItem.fromJson(json))
          .toList();
    }

    return [];
  }

  Future<bool> deleteFile(int fileId) async {
    try {
      await _dio.delete('/files/$fileId');
      return true;
    } catch (_) {
      return false;
    }
  }

  String _extractErrorMessage(Response response) {
    if (response.data is Map && response.data['message'] != null) {
      return response.data['message'].toString();
    }
    return 'Server returned status ${response.statusCode}';
  }

  String _extractDioErrorMessage(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response?.data['message'].toString() ?? 'Network error';
    }
    return e.message ?? 'Network error';
  }
}
