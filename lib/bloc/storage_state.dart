import 'package:vasvault/models/storage_summary.dart';

abstract class StorageState {}

class StorageInitial extends StorageState {}

class StorageLoading extends StorageState {}

class StorageLoaded extends StorageState {
  final StorageSummary storageSummary;

  StorageLoaded(this.storageSummary);
}

class StorageError extends StorageState {
  final String message;

  StorageError(this.message);
}
