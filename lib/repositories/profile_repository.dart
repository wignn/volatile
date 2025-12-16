import 'package:fpdart/fpdart.dart';
import 'package:vasvault/models/profile_response.dart';
import 'package:vasvault/services/api.dart';
import 'package:vasvault/models/update_profile_request.dart';

class ProfileRepository {
  final ApiService _apiService = ApiService();

  Future<Either<String, ProfileResponse>> getProfile() async {
    try {
      final profile = await _apiService.getProfile();
      return Right(profile);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ProfileResponse>> updateProfile(
    UpdateProfileRequest request,
  ) async {
    try {
      final profile = await _apiService.updateProfile(
        username: request.username,
        email: request.email,
        password: request.password,
      );
      return Right(profile);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
