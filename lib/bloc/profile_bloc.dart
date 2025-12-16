import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:vasvault/models/profile_response.dart';
import 'package:vasvault/models/update_profile_request.dart';
import 'package:vasvault/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository = ProfileRepository();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<StartEditingProfile>(_onStartEditingProfile);
    on<CancelEditingProfile>(_onCancelEditingProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _repository.getProfile();
    result.fold(
      (error) => emit(ProfileError(error)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  void _onStartEditingProfile(
    StartEditingProfile event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileEditing(currentState.profile));
    }
  }

  void _onCancelEditingProfile(
    CancelEditingProfile event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileEditing || state is ProfileUpdating) {
      final currentState = state as dynamic;
      emit(ProfileLoaded(currentState.profile));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileEditing) {
      final currentState = state as ProfileEditing;
      emit(ProfileUpdating(currentState.profile));

      final request = UpdateProfileRequest(
        fullName: event.fullName,
        profilePicture: event.profilePicture,
      );

      final result = await _repository.updateProfile(request);
      result.fold(
        (error) => emit(ProfileError(error, profile: currentState.profile)),
        (updatedProfile) => emit(ProfileUpdated(updatedProfile)),
      );
    }
  }
}
