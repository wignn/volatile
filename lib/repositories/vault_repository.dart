import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/file_item.dart';
import 'package:vasvault/services/api.dart';

class VaultRepository {
  final _apiService = ApiService();

  Future<Either<String, List<FileItem>>> getFiles() async {
    try {
      final result = await _apiService.getFiles();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('Koneksi internet bermasalah');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis, silakan login kembali';
      case 403:
        return 'Akses ditolak';
      case 404:
        return 'Data tidak ditemukan';
      case 500:
        return 'Server error, coba lagi nanti';
      default:
        return 'Gagal memuat file: ${e.response?.statusCode ?? 'Unknown error'}';
    }
  }
}
