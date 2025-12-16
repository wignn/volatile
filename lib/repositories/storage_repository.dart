import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:vasvault/models/storage_summary.dart';
import 'package:vasvault/services/api.dart';

class StorageRepository {
  final _apiService = ApiService();

  Future<Either<String, StorageSummary>> getStorageSummary() async {
    try {
      final result = await _apiService.getStorageSummary();
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
        return 'Server tidak ditemukan';
      case 500:
        return 'Server error, coba lagi nanti';
      default:
        return 'Gagal memuat data: ${e.response?.statusCode ?? 'Unknown error'}';
    }
  }
}
