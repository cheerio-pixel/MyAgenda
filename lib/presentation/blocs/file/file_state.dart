part of 'file_bloc.dart';

enum FileStatus { initial, loading, loaded, error }

class FileState extends Equatable {
  final FileStatus status;
  final List<String> files;
  final String? currentFilePath;
  final String? error;

  const FileState({
    this.status = FileStatus.initial,
    this.files = const [],
    this.currentFilePath,
    this.error,
  });

  FileState copyWith({
    FileStatus? status,
    List<String>? files,
    String? currentFilePath,
    String? error,
  }) {
    return FileState(
      status: status ?? this.status,
      files: files ?? this.files,
      currentFilePath: currentFilePath ?? this.currentFilePath,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, files, currentFilePath, error];
}
