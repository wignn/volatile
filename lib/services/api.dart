import 'package:dio/dio.dart';
import 'package:vasvault/constants/app_constant.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/file_item.dart';
import 'package:vasvault/models/file_upload_response.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/models/profile_response.dart'; // TAMBAH INI
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/utils/session_meneger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final baseURL = AppConstants.baseUrl;
  final apiKey = AppConstants.tokenKey;
  late final Dio dio;
  final SessionManager _session = SessionManager();

  bool _isRefreshing = false;

  ApiService._internal() {
    dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;

            try {
              final newTokens = await _refreshToken();

              if (newTokens != null) {
                await _session.saveSession(
                  newTokens.accessToken,
                  newTokens.refreshToken,
                  await _session.getId(),
                );

                final opts = error.requestOptions;
                opts.headers['Authorization'] =
                    'Bearer ${newTokens.accessToken}';

                final response = await dio.fetch(opts);
                _isRefreshing = false;
                return handler.resolve(response);
              }
            } catch (e) {
              _isRefreshing = false;
              await _session.removeAccessToken();
            }

            _isRefreshing = false;
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<AuthResponseModel?> _refreshToken() async {
    try {
      String refreshToken = await _session.getRefreshToken();
      if (refreshToken.isEmpty) return null;

      final response = await Dio().post(
        '$baseURL/api/v1/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
    String refreshToken = await _session.getRefreshToken();
    final response = await dio.post(
      '$baseURL/api/v1/refresh',
      data: {'refresh_token': refreshToken},
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

  Future<ProfileResponse> getProfile() async {
    final session = SessionManager();
    final accessToken = await session.getAccessToken();

    final response = await dio.get(
      '$baseURL/api/v1/me',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'Authorization': 'Bearer $accessToken',
        },
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(response.data);
    }

    var serverMessage =
        'Server returned status ${response.statusCode}: ${response.statusMessage}';
    if (response.data is Map && response.data['message'] != null) {
      serverMessage = response.data['message'].toString();
    }

    throw Exception(serverMessage);
  }

  Future<ProfileResponse> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    final session = SessionManager();
    final accessToken = await session.getAccessToken();

    final response = await dio.put(
      '$baseURL/api/v1/profile',
      data: {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'Authorization': 'Bearer $accessToken',
        },
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(response.data);
    }

    var serverMessage =
        'Server returned status ${response.statusCode}: ${response.statusMessage}';
    if (response.data is Map && response.data['message'] != null) {
      serverMessage = response.data['message'].toString();
    }

    throw Exception(serverMessage);
  }

  Future<StorageSummary> getStorageSummary() async {
    String accessToken = await _session.getAccessToken();
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
    String accessToken = await _session.getAccessToken();

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
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
      final data = response.data['data'];
      return FileUploadResponse.fromJson(data);
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

    if (response.statusCode == 200) {
      try {
        List<dynamic> data;
        if (response.data is Map) {
          final map = response.data as Map<String, dynamic>;

          if (map['files'] != null) {
            data = map['files'] as List<dynamic>;
          } else if (map['data'] != null && map['data'] is List) {
            data = map['data'] as List<dynamic>;
          } else if (map['items'] != null) {
            data = map['items'] as List<dynamic>;
          } else {
            return [];
          }
        } else if (response.data is List) {
          data = response.data as List<dynamic>;
        } else {
          throw Exception(
            'Unexpected response format: ${response.data.runtimeType}',
          );
        }

        return data.map((json) => FileItem.fromJson(json)).toList();
      } catch (e) {
        rethrow;
      }
    }
    throw Exception(
      'Server returned status ${response.statusCode}: ${response.statusMessage}',
    );
  }
}
