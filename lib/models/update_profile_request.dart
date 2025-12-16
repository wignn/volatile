class UpdateProfileRequest {
  final String fullName;
  final String? profilePicture;

  UpdateProfileRequest({
    required this.fullName,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      if (profilePicture != null) 'profile_picture': profilePicture,
    };
  }
}