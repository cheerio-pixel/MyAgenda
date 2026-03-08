part of 'file_bloc.dart';

abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

class LoadFiles extends FileEvent {
  const LoadFiles();
}

class OpenFile extends FileEvent {
  final String filePath;
  const OpenFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class CreateFile extends FileEvent {
  final String fileName;
  const CreateFile(this.fileName);

  @override
  List<Object?> get props => [fileName];
}

class SelectFile extends FileEvent {
  final String filePath;
  const SelectFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DeleteFile extends FileEvent {
  final String filePath;
  const DeleteFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class RefreshFiles extends FileEvent {
  const RefreshFiles();
}
