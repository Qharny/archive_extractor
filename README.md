A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.
# Archive Extractor

A Dart command-line utility for extracting various archive formats (.zip, .tar, .tar.gz, .tgz, .rar).

## Features

- Extract .zip files using pure Dart implementation
- Extract .tar and .tar.gz/.tgz files
- Extract .rar files (requires external unrar utility)
- Command-line interface for single extraction or batch processing
- Detailed extraction reports
- Structured API for use in other Dart applications

## Installation

### Prerequisites

- Dart SDK 3.0 or higher
- unrar command-line utility (for RAR extraction)

### Install unrar

**Ubuntu/Debian:**
```bash
sudo apt-get install unrar
```

**macOS (using Homebrew):**
```bash
brew install unrar
```

**Windows:**
Download from [RARLab](https://www.rarlab.com/rar_add.htm) and add to PATH.

### Install from source

Clone the repository and install dependencies:

```bash
git clone https://github.com/qharny/archive_extractor.git
cd archive_extractor
dart pub get
```

Build the executable:

```bash
dart compile exe bin/archive_extractor.dart -o archive_extractor
```

## Usage

### Command-line interface

Extract a single archive:

```bash
./archive_extractor extract path/to/archive.zip destination/folder
```

Extract all archives in a directory:

```bash
./archive_extractor batch path/to/archives destination/folder
```

Show help:

```bash
./archive_extractor help
```

### Usage as a library

In your `pubspec.yaml`:

```yaml
dependencies:
  archive_extractor:
    path: path/to/archive_extractor
```

In your Dart code:

```dart
import 'package:archive_extractor/archive_extractor.dart';

void main() async {
  // Extract a single archive
  final result = await ArchiveExtractor.extract(
    'path/to/archive.zip',
    'destination/folder'
  );
  
  if (result.success) {
    print('Successfully extracted ${result.totalFiles} files');
  } else {
    print('Extraction failed: ${result.errorMessage}');
  }
}
```

## API Reference

### ArchiveExtractor

Main class for interacting with the library.

#### Methods

- `static Future<ExtractionResult> extract(String archivePath, String destinationPath)`
  
  Extracts the specified archive to the destination directory.

- `static bool isFormatSupported(String archivePath)`
  
  Checks if the file format is supported based on extension.

- `static List<String> supportedFormats()`
  
  Returns a list of supported archive extensions.

### ExtractionResult

Class representing the result of an extraction operation.

#### Properties

- `bool success`: Whether the extraction succeeded
- `String? errorMessage`: Error message if extraction failed
- `int totalFiles`: Number of files extracted
- `Duration? duration`: Time taken for extraction

## Project Structure

```
archive_extractor/
├── bin/
│   └── archive_extractor.dart        # Command-line interface
├── lib/
│   ├── src/
│   │   ├── extractors/              # Format-specific extractors
│   │   │   ├── base_extractor.dart
│   │   │   ├── zip_extractor.dart
│   │   │   ├── tar_extractor.dart
│   │   │   └── rar_extractor.dart
│   │   ├── models/                  # Data models
│   │   │   └── extraction_result.dart
│   │   └── utils/                   # Utility functions
│   │       └── file_utils.dart
│   └── archive_extractor.dart       # Main library API
└── test/                           # Unit tests
    ├── zip_extractor_test.dart
    ├── tar_extractor_test.dart
    ├── rar_extractor_test.dart
    └── utils_test.dart
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.