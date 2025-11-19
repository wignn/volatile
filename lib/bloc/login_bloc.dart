
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:volatile/models/Login_request.dart';
import 'package:volatile/models/auth_Response.dart';
import 'package:volatile/repositories/login_repository.dart';
import 'package:volatile/utils/session_meneger.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final repository = LoginRepository();
  LoginBloc() : super(LoginInitial()) {
    on<Login>((event, emit) async {
      emit(LoginLoading());
      final result = await repository.login(event.requestBody);
      result.fold((errorMessage) => emit(LoginFailed(errorMessage)), (
          loginData,
          ) {
        final sessionManager = SessionManager();
        sessionManager.saveSession(
            loginData.accessToken,
            loginData.refreshToken,
            loginData.id
        );
        emit(LoginSuccess(loginData));
      });
    });

    on<Logout>((event, emit) async {
      emit(LogoutLoading());
      final sessionManager = SessionManager();
      await sessionManager.removeAccessToken();
      emit(LogoutSuccess());
    });
  }
}