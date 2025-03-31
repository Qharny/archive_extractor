import 'dart:io';
import 'package:archive_extractor/src/extrators/zip_extractor.dart';
import 'package:test/test.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;
  late String zipPath;
  
  setUp(() async {
    // Create a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('zip_test_');
    
    // Create a test zip file
    zipPath = path.join(tempDir.path, 'test.zip');
    await _createTestZipFile(zipPath);
  });
  
  tearDown(() async {
    // Clean up the temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  
  test('ZipExtractor extracts files correctly', () async {
    // Create an extractor
    final extractor = ZipExtractor();
    
    // Create an extraction destination
    final extractPath = path.join(tempDir.path, 'extracted');
    
    // Extract the archive
    final result = await extractor.extract(zipPath, extractPath);
    
    // Verify the result
    expect(result.success, true);
    expect(result.totalFiles, 2);
    
    // Check that the files were extracted
    final file1 = File(path.join(extractPath, 'test1.txt'));
    final file2 = File(path.join(extractPath, 'folder/test2.txt'));
    
    expect(await file1.exists(), true);
    expect(await file2.exists(), true);
    
    // Verify content
    expect(await file1.readAsString(), 'Test file 1 content');
    expect(await file2.readAsString(), 'Test file 2 content');
  });
  
  test('ZipExtractor handles non-existent files', () async {
    // Create an extractor
    final extractor = ZipExtractor();
    
    // Try to extract a non-existent file
    final result = await extractor.extract(
      path.join(tempDir.path, 'nonexistent.zip'),
      path.join(tempDir.path, 'extracted')
    );
    
    // Verify the result
    expect(result.success, false);
    expect(result.errorMessage, contains('Error extracting ZIP'));
  });
}

Future<void> _createTestZipFile(String zipPath) async {
  // Create an archive
  final archive = Archive();
  
  // Add test files to the archive
  final file1 = ArchiveFile('test1.txt', 'Test file 1 content'.length,
      'Test file 1 content'.codeUnits);
  archive.addFile(file1);
  
  // Add a file in a subdirectory
  final file2 = ArchiveFile('folder/test2.txt', 'Test file 2 content'.length,
      'Test file 2 content'.codeUnits);
  archive.addFile(file2);
  
  // Write the archive to disk
  final zipData = ZipEncoder().encode(archive);
  await File(zipPath).writeAsBytes(zipData);
}