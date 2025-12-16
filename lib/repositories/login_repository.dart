import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/services/api.dart';

class LoginRepository {
  final _apiService = ApiService();

  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel requestBody,
  ) async {
    try {
      final result = await _apiService.login(requestBody);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('Koneksi internet bermasalah');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return 'Username atau password tidak valid';
      case 401:
        return 'Username atau password salah';
      case 404:
        return 'Server tidak ditemukan';
      case 500:
        return 'Server error, coba lagi nanti';
      default:
        return 'Gagal login: ${e.response?.statusCode ?? 'Unknown error'}';
    }
  }
}
