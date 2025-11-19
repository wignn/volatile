import 'package:jwt_decoder/jwt_decoder.dart';

class TokenHelper {
  static bool isExpired(String token) {
    if (token.isEmpty) return true;
    return JwtDecoder.isExpired(token);
  }

  static Duration getRemainingTime(String token) {
    if (token.isEmpty) return Duration.zero;
    DateTime expirationDate = JwtDecoder.getExpirationDate(token);
    return expirationDate.difference(DateTime.now());
  }
}