import 'dart:convert';

import 'package:memmap/memmap.dart';
import 'dart:io';

void main() {
  var dir = Directory.systemTemp.createTempSync('memmap_test');
  var path = dir.path + '/memmap_test.dart';
  var file = File(path)..writeAsStringSync('hey');

  var mmap = Mmap(path);
  var str = utf8.decode(mmap.asBytes());

  print(str);

  mmap.close();

  file.deleteSync();
}
