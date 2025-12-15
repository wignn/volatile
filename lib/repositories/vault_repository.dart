import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/file_item.dart';
import 'package:vasvault/services/api.dart';

class VaultRepository {
  final apiService = ApiService();

  Future<Either<String, List<FileItem>>> getFiles() async {
    try {
      final result = await apiService.getFiles();
      return Right(result);
    } catch (e) {
      print('VaultRepository Error: $e');
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 401:
            return Left('Sesi habis, silakan login kembali');
          case 403:
            return Left('Akses ditolak');
          case 404:
            return Left('Data tidak ditemukan');
          case 500:
            return Left('Server error, coba lagi nanti');
          default:
            return Left(
              'Gagal memuat file: ${e.response?.statusCode ?? 'Unknown error'}',
            );
        }
      }
      return Left('Koneksi internet bermasalah: ${e.toString()}');
    }
  }
}
