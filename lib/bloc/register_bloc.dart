import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volatile/models/auth_Response.dart';
import 'package:volatile/models/register_request.dart';

import 'package:volatile/repositories/register_repository.dart';
import 'package:meta/meta.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<SignupEvent, SignupState> {
  final repository = SignupRepository();
  RegisterBloc() : super(SignupInitial()) {
    on<Signup>((event, emit) async {
      emit(SignupLoading());
      final result = await repository.signup(event.requestBody);
      result.fold((errorMessage) => emit(SignupFailed(errorMessage)), (
          loginData,
          ) {
        emit(SignupSuccess(loginData));
      });
    });
  }
}