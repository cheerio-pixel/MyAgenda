import '../../domain/entities/outline_tree.dart';

abstract class FileRepository {
  /// Get the documents directory path
  Future<String> getDocumentsDirectory();

  /// List all markdown files in the workspace
  Future<List<String>> listFiles();

  /// Read a file and return its content
  Future<String> readFile(String filePath);

  /// Write content to a file
  Future<void> writeFile(String filePath, String content);

  /// Create a new file with initial content
  Future<String> createFile(String fileName, {String? content});

  /// Delete a file
  Future<void> deleteFile(String filePath);

  /// Check if a file exists
  Future<bool> fileExists(String filePath);

  /// Get file name from path (without extension)
  String getFileName(String filePath);

  /// Watch for file changes
  Stream<List<String>> watchFiles();
}
