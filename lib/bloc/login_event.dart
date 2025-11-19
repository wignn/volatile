part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {
  const LoginEvent();
}

final class Login extends LoginEvent {
  final LoginRequestModel requestBody;
  const Login(this.requestBody);
}

final class Logout extends LoginEvent {}