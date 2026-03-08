import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/local_file_repository.dart';

part 'file_event.dart';
part 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final LocalFileRepository _repository;

  FileBloc({LocalFileRepository? repository})
    : _repository = repository ?? LocalFileRepository(),
      super(const FileState()) {
    on<LoadFiles>(_onLoadFiles);
    on<OpenFile>(_onOpenFile);
    on<CreateFile>(_onCreateFile);
    on<SelectFile>(_onSelectFile);
    on<DeleteFile>(_onDeleteFile);
    on<RefreshFiles>(_onRefreshFiles);
  }

  Future<void> _onLoadFiles(LoadFiles event, Emitter<FileState> emit) async {
    emit(state.copyWith(status: FileStatus.loading));
    try {
      final files = await _repository.listFiles();
      emit(state.copyWith(status: FileStatus.loaded, files: files));
    } catch (e) {
      emit(state.copyWith(status: FileStatus.error, error: e.toString()));
    }
  }

  Future<void> _onOpenFile(OpenFile event, Emitter<FileState> emit) async {
    emit(state.copyWith(currentFilePath: event.filePath));
  }

  Future<void> _onCreateFile(CreateFile event, Emitter<FileState> emit) async {
    try {
      final filePath = await _repository.createFile(event.fileName);
      final files = await _repository.listFiles();
      emit(state.copyWith(files: files, currentFilePath: filePath));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSelectFile(SelectFile event, Emitter<FileState> emit) async {
    emit(state.copyWith(currentFilePath: event.filePath));
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<FileState> emit) async {
    try {
      await _repository.deleteFile(event.filePath);
      final files = await _repository.listFiles();
      String? newCurrentPath;
      if (state.currentFilePath == event.filePath) {
        newCurrentPath = files.isNotEmpty ? files.first : null;
      }
      emit(
        state.copyWith(
          files: files,
          currentFilePath: newCurrentPath ?? state.currentFilePath,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRefreshFiles(
    RefreshFiles event,
    Emitter<FileState> emit,
  ) async {
    try {
      final files = await _repository.listFiles();
      emit(state.copyWith(files: files));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
