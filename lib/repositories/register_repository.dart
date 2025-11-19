import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/services/api.dart';

class SignupRepository {
  final apiService = ApiService();

  Future<Either<String, AuthResponseModel>> signup(
      RegisterRequestModel requestBody,
      ) async {
    try {
      final result = await apiService.signUp(requestBody);
      return Right(result);
    } catch (e) {
      print("🚨 Repository error: $e");
      if (e is DioException) {
        // Prefer server-provided message if present
        final statusCode = e.response?.statusCode;
        String? serverMessage;
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          serverMessage = e.response?.data['message'].toString();
        }

        if (statusCode == 409) {
          return Left(serverMessage ?? 'Email already registered');
        }

        switch (statusCode) {
          case 400:
            return Left(serverMessage ?? 'Username atau password tidak valid');
          case 401:
            return Left(serverMessage ?? 'Username atau password salah');
          case 404:
            return Left(serverMessage ?? 'Server tidak ditemukan');
          case 500:
            return Left(serverMessage ?? 'Server error, coba Lagi nanti');
          default:
            return Left(
              serverMessage ?? 'Gagal registrasi: ${statusCode ?? 'Unknown error'}',
            );
        }
      } else if (e is Exception) {
        // Jika ApiService melempar Exception (mis. 'Server returned status ...'), kembalikan pesannya
        final message = e.toString().replaceFirst('Exception: ', '');
        return Left(message);
      }
      return Left('Koneksi internet bermasalah');
    }
  }
}