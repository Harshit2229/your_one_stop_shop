import 'package:flutter_bloc/flutter_bloc.dart';


import '../../api_services.dart';
import '../../storage/storage_services.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthBloc({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final token = await _apiService.login(event.username, event.password);
      await _storageService.saveToken(token);
      emit(Authenticated(token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _storageService.deleteToken();
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    final token = await _storageService.getToken();
    if (token != null) {
      emit(Authenticated(token));
    } else {
      emit(Unauthenticated());
    }
  }
}