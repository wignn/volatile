import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vasvault/constants/app_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  Future<void> saveSession(
      String accessToken,
      String refreshToken,
      int id,
      ) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppConstants.accessToken, accessToken);
    await pref.setString(AppConstants.refreshToken, refreshToken);
    await pref.setInt(AppConstants.id, id);
  }

  Future<String> getAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    final accessToken = pref.getString(AppConstants.accessToken);

    return accessToken ?? '';
  }

  Future<String> getRefreshToken() async {
    final pref = await SharedPreferences.getInstance();
    final refreshToken = pref.getString(AppConstants.refreshToken);

    return refreshToken ?? '';
  }

  Future<int> getId() async {
    final pref = await SharedPreferences.getInstance();
    final id = pref.getInt(AppConstants.id);

    return id ?? 0;
  }

  Future<bool> shouldRefreshToken() async {
    final accessToken = await getAccessToken();

    if (accessToken.isEmpty) {
      return false;
    }

    try {
      final decodedToken = JwtDecoder.decode(accessToken);
      final expirationTime =
      DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      final now = DateTime.now();

      return expirationTime.difference(now).inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  Future<void> removeAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(AppConstants.id);
    await pref.remove(AppConstants.accessToken);
    await pref.remove(AppConstants.refreshToken);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.id);
  }
}
