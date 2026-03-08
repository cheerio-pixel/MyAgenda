import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/outline_tree.dart';
import '../../domain/repositories/file_repository.dart';

class LocalFileRepository implements FileRepository {
  String? _documentsPath;

  Future<String> _getDocumentsPath() async {
    if (_documentsPath != null) return _documentsPath!;

    final directory = await getApplicationDocumentsDirectory();
    _documentsPath = '${directory.path}/MyAgenda';

    // Create directory if it doesn't exist
    final dir = Directory(_documentsPath!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return _documentsPath!;
  }

  @override
  Future<String> getDocumentsDirectory() async {
    return _getDocumentsPath();
  }

  @override
  Future<List<String>> listFiles() async {
    final path = await _getDocumentsPath();
    final dir = Directory(path);

    if (!await dir.exists()) {
      return [];
    }

    // Collect files with their modification times
    final fileWithStats = <(String, DateTime)>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.md')) {
        final stat = await entity.stat();
        fileWithStats.add((entity.path, stat.modified));
      }
    }

    // Sort by modification time (most recent first)
    fileWithStats.sort((a, b) => b.$2.compareTo(a.$2));

    return fileWithStats.map((e) => e.$1).toList();
  }

  @override
  Future<String> readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }
    return await file.readAsString();
  }

  @override
  Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  @override
  Future<String> createFile(String fileName, {String? content}) async {
    final path = await _getDocumentsPath();

    // Ensure .md extension
    String finalName = fileName;
    if (!finalName.endsWith('.md')) {
      finalName = '$finalName.md';
    }

    // Handle duplicate names
    String filePath = '$path/$finalName';
    int counter = 1;
    while (await File(filePath).exists()) {
      final baseName = finalName.substring(0, finalName.length - 3);
      filePath = '$path/$baseName ($counter).md';
      counter++;
    }

    // Create file with initial content
    final initialContent = content ?? _defaultContent(getFileName(filePath));
    await writeFile(filePath, initialContent);

    return filePath;
  }

  String _defaultContent(String fileName) {
    return '$fileName:\n  - First task\n  - Second task\n';
  }

  @override
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  @override
  String getFileName(String filePath) {
    final parts = filePath.split('/');
    final nameWithExt = parts.last;
    if (nameWithExt.endsWith('.md')) {
      return nameWithExt.substring(0, nameWithExt.length - 3);
    }
    return nameWithExt;
  }

  @override
  Stream<List<String>> watchFiles() async* {
    // Simple polling-based file watching
    List<String> lastFiles = [];

    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final currentFiles = await listFiles();

      if (_listsDifferent(lastFiles, currentFiles)) {
        yield currentFiles;
        lastFiles = currentFiles;
      }
    }
  }

  bool _listsDifferent(List<String> a, List<String> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }
}
