part of 'register_bloc.dart';

@immutable
sealed class SignupEvent {
  const SignupEvent();
}

final class Signup extends SignupEvent {
  final RegisterRequestModel requestBody;
  const Signup(this.requestBody);
}

final class Logout extends SignupEvent {}