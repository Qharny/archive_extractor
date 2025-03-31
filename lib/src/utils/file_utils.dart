import 'dart:io';
import 'package:path/path.dart' as path;

/// Utility methods for file operations
class FileUtils {
  /// Create a file from bytes, ensuring the parent directory exists
  static Future<void> createFileFromBytes(
    String filePath,
    List<int> bytes,
  ) async {
    final directory = Directory(path.dirname(filePath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    await File(filePath).writeAsBytes(bytes);
  }

  /// Check if a file exists
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  /// Get the file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Get the file extension (including compound extensions like .tar.gz)
  static String getFileExtension(String filePath) {
    final filename = path.basename(filePath);
    if (filename.endsWith('.tar.gz')) {
      return '.tar.gz';
    }
    return path.extension(filePath);
  }

  /// Check if a path is an archive file
  static bool isArchiveFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.zip', '.rar', '.tar', '.tar.gz', '.tgz'].contains(extension);
  }
}
