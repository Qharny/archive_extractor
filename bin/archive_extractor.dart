import 'dart:io';
import 'package:archive_extractor/archive_extractor.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    printUsage();
    exit(1);
  }

  final command = arguments[0];

  switch (command) {
    case 'extract':
      if (arguments.length < 3) {
        print('Error: Not enough arguments for extraction');
        printUsage();
        exit(1);
      }
      await extractArchive(arguments[1], arguments[2]);
      break;
    
    case 'batch':
      if (arguments.length < 3) {
        print('Error: Not enough arguments for batch extraction');
        printUsage();
        exit(1);
      }
      await batchExtract(arguments[1], arguments[2]);
      break;
    
    case 'help':
      printUsage();
      break;
    
    default:
      print('Unknown command: $command');
      printUsage();
      exit(1);
  }
}

void printUsage() {
  print('''
Archive Extractor - A tool for extracting various archive formats

Usage:
  archive_extractor extract <archive-path> <destination-path>
    Extract a single archive to the specified destination

  archive_extractor batch <source-directory> <destination-directory>
    Extract all supported archives in the source directory

  archive_extractor help
    Show this help message

Supported formats: .zip, .tar, .tar.gz, .tgz, .rar
''');
}

Future<void> extractArchive(String archivePath, String destinationPath) async {
  final file = File(archivePath);
  
  if (!await file.exists()) {
    print('Error: Archive file not found: $archivePath');
    exit(1);
  }
  
  print('Extracting: $archivePath to $destinationPath');
  
  final result = await ArchiveExtractor.extract(archivePath, destinationPath);
  
  if (result.success) {
    print('Successfully extracted ${result.totalFiles} files');
    print('Archive extracted to: $destinationPath');
  } else {
    print('Failed to extract archive: ${result.errorMessage}');
    exit(1);
  }
}

Future<void> batchExtract(String sourceDir, String destinationDir) async {
  final directory = Directory(sourceDir);
  
  if (!await directory.exists()) {
    print('Error: Source directory not found: $sourceDir');
    exit(1);
  }
  
  print('Scanning directory: $sourceDir');
  
  int successCount = 0;
  int failureCount = 0;
  
  await for (final entity in directory.list()) {
    if (entity is File) {
      final extension = path.extension(entity.path).toLowerCase();
      final fullExtension = _getFullExtension(entity.path);
      
      if (['.zip', '.rar', '.tar', '.tgz', '.gz'].contains(extension) || 
          fullExtension == '.tar.gz') {
        final archiveName = path.basenameWithoutExtension(entity.path);
        final extractPath = path.join(destinationDir, archiveName);
        
        print('\nExtracting: ${entity.path}');
        final result = await ArchiveExtractor.extract(entity.path, extractPath);
        
        if (result.success) {
          print('Successfully extracted ${result.totalFiles} files to $extractPath');
          successCount++;
        } else {
          print('Failed to extract: ${result.errorMessage}');
          failureCount++;
        }
      }
    }
  }
  
  print('\nBatch extraction complete');
  print('Successfully extracted: $successCount archives');
  print('Failed to extract: $failureCount archives');
}

String _getFullExtension(String filePath) {
  final filename = path.basename(filePath);
  if (filename.endsWith('.tar.gz')) {
    return '.tar.gz';
  }
  return path.extension(filePath);
}