import 'dart:convert';

import 'package:memmap/memmap.dart';
import 'package:memmap/libc.dart' as libc;
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Open/close File', () {
      var fd = libc.open('test/memmap_test.dart', 0, 0);
      libc.close(fd);
    });

    test('Page size', () {
      var page_size = libc.pageSize();
      expect(page_size, equals(4096));
    });

    test('Memmap', () {
      var dir = Directory.systemTemp.createTempSync('memmap_test');
      var path = dir.path + '/test';
      var file = File(path)..writeAsStringSync('hey');

      var mmap = Mmap(path);
      var bytes = mmap.asBytes();

      expect(bytes, equals(utf8.encode('hey')));

      mmap.close();

      file.deleteSync();
    });

    test('Empty file', () async {
      var dir = Directory.systemTemp.createTempSync('memmap_test');
      var path = dir.path + '/empty';
      var file = File(path)..writeAsStringSync('');

      var mmap = await Mmap.create(path);
      var bytes = mmap.asBytes();

      expect(bytes, equals(utf8.encode('')));

      mmap.close();

      file.deleteSync();
    });
  });
}
