part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {
  const ProfileEvent();
}

final class LoadProfile extends ProfileEvent {}

final class StartEditingProfile extends ProfileEvent {}

final class CancelEditingProfile extends ProfileEvent {}

final class UpdateProfileEvent extends ProfileEvent {
  final String? username;
  final String? email;
  final String? password;

  const UpdateProfileEvent({
    this.username,
    this.email,
    this.password,
  });
}