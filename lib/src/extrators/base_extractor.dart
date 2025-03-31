import 'package:archive_extractor/src/models/extration_result.dart';

/// Base abstract class for all archive extractors
abstract class BaseExtractor {
  /// Extract an archive file to a destination directory
  ///
  /// Parameters:
  /// - [archivePath]: Path to the archive file
  /// - [destinationPath]: Directory where files will be extracted
  ///
  /// Returns an [ExtractionResult] with information about the extraction
  Future<ExtractionResult> extract(String archivePath, String destinationPath);
}
