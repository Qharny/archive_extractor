import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive_extractor/src/models/extration_result.dart';
import 'package:path/path.dart' as path;

import '../utils/file_utils.dart';
import 'base_extractor.dart';

/// Extractor for TAR archives (including compressed variants)
class TarExtractor implements BaseExtractor {
  @override
  Future<ExtractionResult> extract(
    String archivePath,
    String destinationPath,
  ) async {
    try {
      // Read the archive file
      final bytes = await File(archivePath).readAsBytes();

      Archive archive;

      // Handle different TAR compressions
      if (archivePath.endsWith('.tar.gz') || archivePath.endsWith('.tgz')) {
        // Decompress with GZip first, then extract TAR
        final gzBytes = GZipDecoder().decodeBytes(bytes);
        archive = TarDecoder().decodeBytes(gzBytes);
      } else {
        // Regular TAR file
        archive = TarDecoder().decodeBytes(bytes);
      }

      int extractedFiles = 0;

      // Process each file in the archive
      for (final file in archive) {
        final filePath = path.join(destinationPath, file.name);

        if (file.isFile) {
          // Extract file
          final data = file.content as List<int>;
          await FileUtils.createFileFromBytes(filePath, data);
          extractedFiles++;
        } else {
          // Create directory
          await Directory(filePath).create(recursive: true);
        }
      }

      return ExtractionResult(success: true, totalFiles: extractedFiles);
    } catch (e) {
      return ExtractionResult(
        success: false,
        errorMessage: 'Error extracting TAR: $e',
        totalFiles: 0,
      );
    }
  }
}
