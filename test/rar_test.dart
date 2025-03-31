import 'dart:io';
import 'package:archive_extractor/src/extrators/rar_extractor.dart';
import 'package:test/test.dart';
import 'package:archive_extractor/archive_extractor.dart';
import 'package:path/path.dart' as path;

void main() {
  // Note: These tests depend on the unrar utility being installed
  // and may be skipped if it's not available

  late Directory tempDir;
  
  setUp(() async {
    // Create a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('rar_test_');
  });
  
  tearDown(() async {
    // Clean up the temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  
  test('RarExtractor detects missing unrar utility', () async {
    // Skip test if unrar is actually installed to avoid false positives
    final whichProcess = await Process.run('which', ['unrar']);
    if (whichProcess.exitCode == 0) {
      // Mocking the absence of unrar is difficult in this test environment
      // So we'll skip if it's actually installed
      skip('unrar is installed, cannot test the absence of it');
    }
    
    // Create an extractor
    final extractor = RarExtractor();
    
    // Try to extract a non-existent file (doesn't matter because check for unrar comes first)
    final result = await extractor.extract(
      path.join(tempDir.path, 'nonexistent.rar'),
      path.join(tempDir.path, 'extracted')
    );
    
    // Verify the result indicates missing unrar
    expect(result.success, false);
    expect(result.errorMessage, contains('unrar utility not found'));
  });
  
  test('RarExtractor handles non-existent files', () async {
    // Skip test if unrar is not installed
    final whichProcess = await Process.run('which', ['unrar']);
    if (whichProcess.exitCode != 0) {
      skip('unrar is not installed, skipping test');
    }
    
    // Create an extractor
    final extractor = RarExtractor();
    
    // Try to extract a non-existent file
    final result = await extractor.extract(
      path.join(tempDir.path, 'nonexistent.rar'),
      path.join(tempDir.path, 'extracted')
    );
    
    // Verify the result
    expect(result.success, false);
  });
  
  // Note: We can't easily create a real RAR file in the test because the RAR format
  // requires the proprietary RAR library or command-line utility to create.
  // A full test would require a pre-made RAR file to be included with the tests.
}