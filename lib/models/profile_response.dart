class ProfileResponse {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? profilePicture;
  final DateTime? createdAt;

  ProfileResponse({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.profilePicture,
    this.createdAt,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>? ?? json;
    
    return ProfileResponse(
      id: user['id'] as int? ?? 0,
      username: user['username'] as String? ?? '',
      fullName: user['full_name'] as String? ?? user['username'] ?? '',
      email: user['email'] as String? ?? '',
      profilePicture: user['profile_picture'] as String?,
      createdAt: user['created_at'] != null
          ? DateTime.tryParse(user['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'profile_picture': profilePicture,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}