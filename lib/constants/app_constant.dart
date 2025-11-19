import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConstants {
  static final String baseUrl =
  const String.fromEnvironment('BASE_URL', defaultValue: '')
      .isNotEmpty
      ? const String.fromEnvironment('BASE_URL')
      : (dotenv.env['BASE_URL'] ?? '');

  static final String tokenKey =
  const String.fromEnvironment('TOKEN_KEY', defaultValue: '')
      .isNotEmpty
      ? const String.fromEnvironment('TOKEN_KEY')
      : (dotenv.env['TOKEN_KEY'] ?? '');

  static const accessToken = 'accessToken';
  static const refreshToken = 'backendToken';
  static const id = 'id';
}