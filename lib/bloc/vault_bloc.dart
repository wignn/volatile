import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/vault_event.dart';
import 'package:vasvault/bloc/vault_state.dart';
import 'package:vasvault/repositories/vault_repository.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final VaultRepository _vaultRepository;

  VaultBloc({VaultRepository? vaultRepository})
    : _vaultRepository = vaultRepository ?? VaultRepository(),
      super(VaultInitial()) {
    on<LoadVaultFiles>(_onLoadVaultFiles);
    on<RefreshVaultFiles>(_onRefreshVaultFiles);
  }

  Future<void> _onLoadVaultFiles(
    LoadVaultFiles event,
    Emitter<VaultState> emit,
  ) async {
    emit(VaultLoading());
    final result = await _vaultRepository.getFiles();
    result.fold(
      (error) => emit(VaultError(error)),
      (files) => emit(VaultLoaded(files)),
    );
  }

  Future<void> _onRefreshVaultFiles(
    RefreshVaultFiles event,
    Emitter<VaultState> emit,
  ) async {
    final result = await _vaultRepository.getFiles();
    result.fold(
      (error) => emit(VaultError(error)),
      (files) => emit(VaultLoaded(files)),
    );
  }
}
