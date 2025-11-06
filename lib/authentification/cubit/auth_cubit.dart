import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transi_flex_mobile/authentification/model/user.dart';

import '../model/auth_request.dart';
import '../repository/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final result = await authRepository.getCurrentUser();
    result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    print("email" + email);
    print(password);
    final request = LoginRequest(username: email, password: password);
    final result = await authRepository.login(request);

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> register({
    required String email,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    emit(AuthLoading());

    try {
      final request = RegisterRequest(
        firstName: prenom,
        lastName: nom,
        email: email,
        phoneNumber: telephone,
      );

      final result = await authRepository.register(request);

      result.fold(
            (failure) => emit(AuthError(message: failure.message)),
            (user) => emit(AuthAuthenticated(user: user)),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }


  Future<void> logout() async {
    emit(AuthLoading());

    final result = await authRepository.logout();
    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> refreshToken() async {
    final result = await authRepository.refreshToken();
    result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (success) {
        if (!success) {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
  void resetToUnauthenticated() {
    emit(AuthUnauthenticated());
  }
}
