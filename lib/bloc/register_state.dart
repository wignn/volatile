part of 'register_bloc.dart';

@immutable
sealed class SignupState {
  const SignupState();
}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupSuccess extends SignupState {
  final AuthResponseModel signupData;
  const SignupSuccess(this.signupData);
}

final class SignupFailed extends SignupState {
  final String errorMessage;
  const SignupFailed(this.errorMessage);
}