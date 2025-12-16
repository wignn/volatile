part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileResponse profile;
  const ProfileLoaded(this.profile);
}

final class ProfileEditing extends ProfileState {
  final ProfileResponse profile;
  const ProfileEditing(this.profile);
}

final class ProfileUpdating extends ProfileState {
  final ProfileResponse profile;
  const ProfileUpdating(this.profile);
}

final class ProfileUpdated extends ProfileState {
  final ProfileResponse profile;
  const ProfileUpdated(this.profile);
}

final class ProfileError extends ProfileState {
  final String message;
  final ProfileResponse? profile;
  const ProfileError(this.message, {this.profile});
}