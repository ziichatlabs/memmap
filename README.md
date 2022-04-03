

A Linux memory mapped IO.

## Features

- [x] file-backed memory maps
- [] anonymous memory maps
- [] synchronous and asynchronous flushing
- [] copy-on-write memory maps
- [] read-only memory maps
- [] stack support (`MAP_STACK` on unix)
- [] executable memory maps
- [ ] huge page support

## Usage

```dart
var dir = Directory.systemTemp.createTempSync('memmap_test');
var path = dir.path + '/memmap_test.dart';
var file = File(path)..writeAsStringSync('hey');

var mmap = Mmap(path);
var bytes = mmap.asBytes();

expect(bytes, equals(utf8.encode('hey')));

mmap.close();

file.deleteSync();
```

 

  