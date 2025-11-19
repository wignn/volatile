import 'package:dio/dio.dart';
import 'package:vasvault/constants/app_constant.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/models/register_request.dart';
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
      String serverMessage = 'Server returned status ${response.statusCode}: ${response.statusMessage}';
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

}