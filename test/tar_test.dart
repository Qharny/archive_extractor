import 'dart:io';
import 'package:archive_extractor/src/extrators/tar_extractor.dart';
import 'package:test/test.dart';
import 'package:archive/archive.dart';
// import 'package:archive_extractor/archive_extractor.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;
  late String tarPath;
  late String tarGzPath;
  
  setUp(() async {
    // Create a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('tar_test_');
    
    // Create test tar files
    tarPath = path.join(tempDir.path, 'test.tar');
    tarGzPath = path.join(tempDir.path, 'test.tar.gz');
    
    await _createTestTarFile(tarPath);
    await _createTestTarGzFile(tarGzPath);
  });
  
  tearDown(() async {
    // Clean up the temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  
  test('TarExtractor extracts TAR files correctly', () async {
    // Create an extractor
    final extractor = TarExtractor();
    
    // Create an extraction destination
    final extractPath = path.join(tempDir.path, 'extracted_tar');
    
    // Extract the archive
    final result = await extractor.extract(tarPath, extractPath);
    
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
  
  test('TarExtractor extracts TAR.GZ files correctly', () async {
    // Create an extractor
    final extractor = TarExtractor();
    
    // Create an extraction destination
    final extractPath = path.join(tempDir.path, 'extracted_targz');
    
    // Extract the archive
    final result = await extractor.extract(tarGzPath, extractPath);
    
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
}

Future<void> _createTestTarFile(String tarPath) async {
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
  final tarData = TarEncoder().encode(archive);
  await File(tarPath).writeAsBytes(tarData);
}

Future<void> _createTestTarGzFile(String tarGzPath) async {
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
  
  // Create a tar first
  final tarData = TarEncoder().encode(archive);
  
  // Then compress with gzip
  final gzData = GZipEncoder().encode(tarData);
  
  // Write to disk
  await File(tarGzPath).writeAsBytes(gzData);
}