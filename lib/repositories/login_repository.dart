import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/services/api.dart';

class LoginRepository {
  final apiService = ApiService();

  Future<Either<String, AuthResponseModel>> login(
      LoginRequestModel requestBody,
      ) async {
    try {
      final result = await apiService.login(requestBody);
      print(result);
      return Right(result);
    } catch (e) {
      print(" Repository error: $e");
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 400:
            return Left('Username atau password tidak valid');
          case 401:
            return Left('Username atau password salah');
          case 404:
            return Left('Server tidak ditemukan');
          case 500:
            return Left('Server error, coba lagi nanti');
          default:
            return Left(
              'Gagal login: ${e.response?.statusCode ?? 'Unknown error'}',
            );
        }
      }
      return Left('Koneksi internet bermasalah');
    }
  }
}