library;

export 'src/utils/file_utils.dart';

// Main class for the archive extractor library
import 'dart:io';
import 'package:archive_extractor/src/extrators/base_extractor.dart';
import 'package:archive_extractor/src/extrators/rar_extractor.dart';
import 'package:archive_extractor/src/extrators/tar_extractor.dart';
import 'package:archive_extractor/src/extrators/zip_extractor.dart';
import 'package:archive_extractor/src/models/extration_result.dart';
import 'package:path/path.dart' as path;

/// Main class for extracting archives of various formats
class ArchiveExtractor {
  /// Extract an archive file to the specified destination
  /// Returns an [ExtractionResult] with information about the extraction
  static Future<ExtractionResult> extract(
    String archivePath,
    String destinationPath,
  ) async {
    final extension = path.extension(archivePath).toLowerCase();
    final fullPath = path.absolute(archivePath);

    // Check if the file exists
    if (!await File(fullPath).exists()) {
      return ExtractionResult(
        success: false,
        errorMessage: 'Archive file not found: $archivePath',
        totalFiles: 0,
      );
    }

    // Create destination directory if it doesn't exist
    final destinationDir = Directory(destinationPath);
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    BaseExtractor extractor;

    // Select the appropriate extractor based on file extension
    if (extension == '.zip') {
      extractor = ZipExtractor();
    } else if (extension == '.tar' ||
        extension == '.tgz' ||
        archivePath.endsWith('.tar.gz')) {
      extractor = TarExtractor();
    } else if (extension == '.rar') {
      extractor = RarExtractor();
    } else {
      return ExtractionResult(
        success: false,
        errorMessage: 'Unsupported archive format: $extension',
        totalFiles: 0,
      );
    }

    // Perform the extraction
    return await extractor.extract(fullPath, destinationPath);
  }

  /// Check if the format is supported
  static bool isFormatSupported(String archivePath) {
    final extension = path.extension(archivePath).toLowerCase();
    return ['.zip', '.tar', '.rar', '.tgz', '.gz'].contains(extension) ||
        archivePath.endsWith('.tar.gz');
  }

  /// Get list of supported formats
  static List<String> supportedFormats() {
    return ['.zip', '.tar', '.tar.gz', '.tgz', '.rar'];
  }
}
