import 'dart:io';
import 'package:archive_extractor/src/models/extration_result.dart';
import 'package:path/path.dart' as path;

import 'base_extractor.dart';

/// Extractor for RAR archives (requires external unrar utility)
class RarExtractor implements BaseExtractor {
  @override
  Future<ExtractionResult> extract(
    String archivePath,
    String destinationPath,
  ) async {
    try {
      // Ensure destination directory exists
      final directory = Directory(destinationPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Check if unrar is available
      final whichProcess = await Process.run('which', ['unrar']);
      if (whichProcess.exitCode != 0) {
        return ExtractionResult(
          success: false,
          errorMessage:
              'unrar utility not found. Please install unrar to extract RAR archives.',
          totalFiles: 0,
        );
      }

      // Call external unrar command
      final process = await Process.run('unrar', [
        'x',
        '-y',
        archivePath,
        destinationPath,
      ]);

      if (process.exitCode != 0) {
        return ExtractionResult(
          success: false,
          errorMessage: 'Error extracting RAR: ${process.stderr}',
          totalFiles: 0,
        );
      }

      // Count extracted files (approximate)
      final extractedFiles = await _countExtractedFiles(destinationPath);

      return ExtractionResult(success: true, totalFiles: extractedFiles);
    } catch (e) {
      return ExtractionResult(
        success: false,
        errorMessage: 'Error with RAR extraction: $e',
        totalFiles: 0,
      );
    }
  }

  /// Count files in the destination directory as an approximation
  /// of the number of extracted files
  Future<int> _countExtractedFiles(String dirPath) async {
    int count = 0;
    final dir = Directory(dirPath);

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        count++;
      }
    }

    return count;
  }
}
