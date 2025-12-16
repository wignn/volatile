class UpdateProfileRequest {
  final String? username;
  final String? email;
  final String? password;

  UpdateProfileRequest({
    this.username,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    };
  }
}