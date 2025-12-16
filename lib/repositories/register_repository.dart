import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/services/api.dart';

class SignupRepository {
  final _apiService = ApiService();

  Future<Either<String, AuthResponseModel>> signup(
    RegisterRequestModel requestBody,
  ) async {
    try {
      final result = await _apiService.signUp(requestBody);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      // Handle Exception from ApiService
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(message);
    }
  }

  String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    String? serverMessage;

    if (e.response?.data is Map && e.response?.data['message'] != null) {
      serverMessage = e.response?.data['message'].toString();
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Data tidak valid';
      case 401:
        return serverMessage ?? 'Tidak terautentikasi';
      case 404:
        return serverMessage ?? 'Server tidak ditemukan';
      case 409:
        return serverMessage ?? 'Email sudah terdaftar';
      case 500:
        return serverMessage ?? 'Server error, coba lagi nanti';
      default:
        return serverMessage ??
            'Gagal registrasi: ${statusCode ?? 'Unknown error'}';
    }
  }
}
