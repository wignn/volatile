import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/storage_event.dart';
import 'package:vasvault/bloc/storage_state.dart';
import 'package:vasvault/repositories/storage_repository.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageRepository _storageRepository;

  StorageBloc({StorageRepository? storageRepository})
    : _storageRepository = storageRepository ?? StorageRepository(),
      super(StorageInitial()) {
    on<LoadStorageSummary>(_onLoadStorageSummary);
    on<RefreshStorageSummary>(_onRefreshStorageSummary);
  }

  Future<void> _onLoadStorageSummary(
    LoadStorageSummary event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    final result = await _storageRepository.getStorageSummary();
    result.fold(
      (error) => emit(StorageError(error)),
      (data) => emit(StorageLoaded(data)),
    );
  }

  Future<void> _onRefreshStorageSummary(
    RefreshStorageSummary event,
    Emitter<StorageState> emit,
  ) async {
    final result = await _storageRepository.getStorageSummary();
    result.fold(
      (error) => emit(StorageError(error)),
      (data) => emit(StorageLoaded(data)),
    );
  }
}
