/// Class to represent the result of an archive extraction
class ExtractionResult {
  /// Whether the extraction was successful
  final bool success;

  /// Error message if extraction failed
  final String? errorMessage;

  /// Number of files extracted
  final int totalFiles;

  /// Duration of the extraction process
  final Duration? duration;

  ExtractionResult({
    required this.success,
    this.errorMessage,
    required this.totalFiles,
    this.duration,
  });

  @override
  String toString() {
    if (success) {
      final durationStr =
          duration != null ? ' in ${duration!.inMilliseconds}ms' : '';
      return 'ExtractionResult: Success, extracted $totalFiles files$durationStr';
    } else {
      return 'ExtractionResult: Failed, error: $errorMessage';
    }
  }
}
