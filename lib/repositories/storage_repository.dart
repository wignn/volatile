import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/services/api.dart';

class StorageRepository {
  final apiService = ApiService();

  Future<Either<String, StorageSummary>> getStorageSummary() async {
    try {
      final result = await apiService.getStorageSummary();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 401:
            return Left('Sesi habis, silakan login kembali');
          case 403:
            return Left('Akses ditolak');
          case 404:
            return Left('Server tidak ditemukan');
          case 500:
            return Left('Server error, coba lagi nanti');
          default:
            return Left(
              'Gagal memuat data: ${e.response?.statusCode ?? 'Unknown error'}',
            );
        }
      }
      return Left('Koneksi internet bermasalah');
    }
  }
}
