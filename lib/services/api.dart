import 'package:dio/dio.dart';
import 'package:vasvault/constants/app_constant.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/file_item.dart';
import 'package:vasvault/models/file_upload_response.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/utils/session_meneger.dart';

class ApiService {
  final baseURL = AppConstants.baseUrl;
  final apiKey = AppConstants.tokenKey;
  final dio = Dio();

  Future<AuthResponseModel> login(LoginRequestModel requestBody) async {
    final response = await dio.post(
      '$baseURL/api/v1/login',
      data: requestBody.toJson(),
      options: Options(
        headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
      ),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> refreshToken() async {
    final session = SessionManager();
    String refreshToken = await session.getRefreshToken();
    final response = await dio.post(
      '$baseURL/api/v1/refresh',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'Authorization': 'Refresh $refreshToken',
        },
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(response.data);
    }
    throw Exception(
      'Server returned status ${response.statusCode}: ${response.statusMessage}',
    );
  }

  Future<AuthResponseModel> signUp(RegisterRequestModel requestBody) async {
    try {
      final response = await dio.post(
        '$baseURL/api/v1/register',
        data: requestBody.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      }
      String serverMessage =
          'Server returned status ${response.statusCode}: ${response.statusMessage}';
      if (response.data is Map && response.data['message'] != null) {
        serverMessage = response.data['message'].toString();
      }

      throw Exception(serverMessage);
    } on DioException catch (e) {
      String serverMessage = e.message ?? 'Network error';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        serverMessage = e.response?.data['message'].toString() ?? serverMessage;
      }
      throw Exception(serverMessage);
    }
  }

  Future<StorageSummary> getStorageSummary() async {
    final session = SessionManager();
    String accessToken = await session.getAccessToken();
    final response = await dio.get(
      '$baseURL/api/v1/storage/summary',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'Authorization': 'Bearer $accessToken',
        },
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    if (response.statusCode == 200) {
      return StorageSummary.fromJson(response.data);
    }
    throw Exception(
      'Server returned status ${response.statusCode}: ${response.statusMessage}',
    );
  }

  Future<FileUploadResponse> uploadFile({
    required String filePath,
    required String fileName,
    int? folderId,
    List<int>? categoryIds,
    void Function(int sent, int total)? onProgress,
  }) async {
    final session = SessionManager();
    String accessToken = await session.getAccessToken();

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (folderId != null) 'folder_id': folderId,
      if (categoryIds != null && categoryIds.isNotEmpty)
        'category_ids': categoryIds,
    });

    final response = await dio.post(
      '$baseURL/api/v1/files',
      data: formData,
      options: Options(
        headers: {'x-api-key': apiKey, 'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) {
          return status! < 500;
        },
      ),
      onSendProgress: onProgress,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FileUploadResponse.fromJson(response.data);
    }
    String serverMessage =
        'Server returned status ${response.statusCode}: ${response.statusMessage}';
    if (response.data is Map && response.data['message'] != null) {
      serverMessage = response.data['message'].toString();
    }
    throw Exception(serverMessage);
  }

  Future<List<FileItem>> getFiles() async {
    final session = SessionManager();
    String accessToken = await session.getAccessToken();

    print('API: Fetching files from $baseURL/api/v1/files');
    print('API: Access token: ${accessToken.substring(0, 20)}...');

    final response = await dio.get(
      '$baseURL/api/v1/files',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'Authorization': 'Bearer $accessToken',
        },
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    print('API: Response status: ${response.statusCode}');
    print('API: Response data type: ${response.data.runtimeType}');
    print('API: Response data: ${response.data}');

    if (response.statusCode == 200) {
      try {
        List<dynamic> data;
        if (response.data is Map) {
          // Check berbagai kemungkinan key di Map
          final map = response.data as Map<String, dynamic>;
          print('API: Response keys: ${map.keys}');

          if (map['files'] != null) {
            data = map['files'] as List<dynamic>;
          } else if (map['data'] != null && map['data'] is List) {
            data = map['data'] as List<dynamic>;
          } else if (map['items'] != null) {
            data = map['items'] as List<dynamic>;
          } else {
            // Jika tidak ada key yang cocok, return empty list
            print('API: No files found in response, returning empty list');
            return [];
          }
        } else if (response.data is List) {
          data = response.data as List<dynamic>;
        } else {
          throw Exception(
            'Unexpected response format: ${response.data.runtimeType}',
          );
        }

        print('API: Parsing ${data.length} files');
        return data.map((json) => FileItem.fromJson(json)).toList();
      } catch (e) {
        print('API: Error parsing files: $e');
        rethrow;
      }
    }
    throw Exception(
      'Server returned status ${response.statusCode}: ${response.statusMessage}',
    );
  }
}
