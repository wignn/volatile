part of 'login_bloc.dart';

@immutable
sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final AuthResponseModel loginData;
  const LoginSuccess(this.loginData);
}

final class LoginFailed extends LoginState {
  final String errorMessage;
  const LoginFailed(this.errorMessage);
}

// logout
final class LogoutLoading extends LoginState {}

final class LogoutSuccess extends LoginState {}