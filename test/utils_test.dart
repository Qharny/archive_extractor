import 'dart:io';
import 'package:test/test.dart';
import 'package:archive_extractor/archive_extractor.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;
  
  setUp(() async {
    // Create a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('utils_test_');
  });
  
  tearDown(() async {
    // Clean up the temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  
  group('FileUtils', () {
    test('createFileFromBytes creates file with correct content', () async {
      final testFilePath = path.join(tempDir.path, 'test_folder/test_file.txt');
      final testData = 'Hello, world!'.codeUnits;
      
      await FileUtils.createFileFromBytes(testFilePath, testData);
      
      final file = File(testFilePath);
      expect(await file.exists(), true);
      expect(await file.readAsBytes(), testData);
    });
    
    test('fileExists returns correct value', () async {
      final existingFilePath = path.join(tempDir.path, 'existing.txt');
      final nonExistingFilePath = path.join(tempDir.path, 'non_existing.txt');
      
      // Create one file
      await File(existingFilePath).writeAsString('test');
      
      expect(await FileUtils.fileExists(existingFilePath), true);
      expect(await FileUtils.fileExists(nonExistingFilePath), false);
    });
    
    test('getFileSize returns correct size', () async {
      final testFilePath = path.join(tempDir.path, 'size_test.txt');
      final testContent = 'This is a test file with a known size.';
      
      await File(testFilePath).writeAsString(testContent);
      
      final size = await FileUtils.getFileSize(testFilePath);
      expect(size, testContent.length);
      
      // Non-existent file should return 0
      expect(await FileUtils.getFileSize(path.join(tempDir.path, 'nonexistent.txt')), 0);
    });
    
    test('getFileExtension detects simple and compound extensions', () async {
      expect(FileUtils.getFileExtension('test.zip'), '.zip');
      expect(FileUtils.getFileExtension('test.tar.gz'), '.tar.gz');
      expect(FileUtils.getFileExtension('/path/to/archive.tar.gz'), '.tar.gz');
      expect(FileUtils.getFileExtension('noextension'), '');
    });
    
    test('isArchiveFile correctly identifies archive files', () async {
      expect(FileUtils.isArchiveFile('test.zip'), true);
      expect(FileUtils.isArchiveFile('test.rar'), true);
      expect(FileUtils.isArchiveFile('test.tar'), true);
      expect(FileUtils.isArchiveFile('test.tar.gz'), true);
      expect(FileUtils.isArchiveFile('test.tgz'), true);
      
      expect(FileUtils.isArchiveFile('test.txt'), false);
      expect(FileUtils.isArchiveFile('test.jpg'), false);
      expect(FileUtils.isArchiveFile('test'), false);
    });
  });
  
  group('ArchiveExtractor', () {
    test('isFormatSupported correctly identifies supported formats', () {
      expect(ArchiveExtractor.isFormatSupported('test.zip'), true);
      expect(ArchiveExtractor.isFormatSupported('test.rar'), true);
      expect(ArchiveExtractor.isFormatSupported('test.tar'), true);
      expect(ArchiveExtractor.isFormatSupported('test.tar.gz'), true);
      expect(ArchiveExtractor.isFormatSupported('test.tgz'), true);
      
      expect(ArchiveExtractor.isFormatSupported('test.txt'), false);
      expect(ArchiveExtractor.isFormatSupported('test.jpg'), false);
      expect(ArchiveExtractor.isFormatSupported('test'), false);
    });
    
    test('supportedFormats returns the correct list', () {
      final formats = ArchiveExtractor.supportedFormats();
      expect(formats, contains('.zip'));
      expect(formats, contains('.tar'));
      expect(formats, contains('.tar.gz'));
      expect(formats, contains('.tgz'));
      expect(formats, contains('.rar'));
      expect(formats.length, 5);
    });
  });
}