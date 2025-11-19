import 'package:dio/dio.dart';
import 'package:volatile/constants/app_constant.dart';
import 'package:volatile/models/Login_request.dart';
import 'package:volatile/models/auth_Response.dart';
import 'package:volatile/models/register_request.dart';
import 'package:volatile/utils/session_meneger.dart';


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
    } else {
      throw Exception(
        'Server returned status ${response.statusCode}: ${response.statusMessage}',
      );
    }
  }

}