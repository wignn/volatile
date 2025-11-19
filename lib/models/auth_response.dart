class AuthResponseModel {
  final int id;
  final String username;
  final String accessToken;
  final String refreshToken;

  AuthResponseModel({
    required this.id,
    required this.username,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] as Map<String, dynamic>;

    return AuthResponseModel(
      id: user['id'] as int,
      username: user['username'] as String,
      accessToken: token['access_token'] as String,
      refreshToken: token['refresh_token'] as String,
    );
  }
}
