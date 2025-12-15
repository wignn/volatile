import 'package:vasvault/models/file_item.dart';

abstract class VaultState {}

class VaultInitial extends VaultState {}

class VaultLoading extends VaultState {}

class VaultLoaded extends VaultState {
  final List<FileItem> files;

  VaultLoaded(this.files);
}

class VaultError extends VaultState {
  final String message;

  VaultError(this.message);
}
