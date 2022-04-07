import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:memmap/libc.dart' as libc;

class Mmap {
  static const PROT_NONE = 0;
  static const PROT_READ = 1;
  static const PROT_WRITE = 2;
  static const PROT_EXEC = 4;

  static const MAP_FILE = 0x0000;
  static const MAP_SHARED = 0x0001;
  static const MAP_PRIVATE = 0x0002;
  static const MAP_FIXED = 0x0010;

  int _fd;
  MmapInner _inner;

  static  Future<Mmap> create(String fileName,
      {int prot: PROT_READ, int flags: MAP_SHARED, int offset: 0}) async {
    final file = File(fileName);
    final stat = await file.stat();
    final size = stat.size;
    return Mmap._(fileName, size, prot: prot, flags: flags, offset: offset);
  }

  factory Mmap(String fileName,
      {int prot: PROT_READ, int flags: MAP_SHARED, int offset: 0}) {
    final file = File(fileName);
    final stat = file.statSync();
    final size = stat.size;
    return Mmap._(fileName, size, prot: prot, flags: flags, offset: offset);
  }

  Mmap._(String fileName, int size,
      {int prot: PROT_READ, int flags: MAP_SHARED, int offset: 0}) {
    _fd = libc.open(fileName, 0, 0);
    _inner = MmapInner(size, _fd, prot, flags, offset);
  }

  int get length => _inner.len;

  MmapInner get inner => _inner;

  void close() {
    libc.close(_fd);
    _inner?.drop();
    _inner = null;
  }

  Uint8List asBytes() {
    return _inner.asBytes();
  }
}

class MmapInnerImpl implements MmapInner {
  int _ptrAddr;
  int _len;

  MmapInnerImpl._(
      this._len, int file_descriptor, int prot, int flags, int offset) {
    _ptrAddr =
        libc.mmap(nullptr, _len, prot, flags, file_descriptor, offset).address;

    if (_ptrAddr < 0) {
      throw Exception('mmap failed');
    }
  }

  Pointer<Void> get ptr => Pointer.fromAddress(_ptrAddr);

  void drop() {
    var alignment = ptr.address % libc.pageSize();
    if (alignment != 0) {
      var alignedPtr = Pointer<Void>.fromAddress(ptr.address - alignment);
      libc.munmap(alignedPtr, _len + alignment);
    } else {
      libc.munmap(ptr, _len);
    }
  }

  Uint8List asBytes() {
    var bytes = ptr.cast<Uint8>();
    return bytes.asTypedList(_len);
  }

  Uint8List asUint8List() {
    return ptr.cast<Uint8>().asTypedList(_len);
  }

  Uint16List asUint16List() {
    return ptr.cast<Uint16>().asTypedList(_len ~/ 2);
  }

  Uint32List asUint32List() {
    return ptr.cast<Uint32>().asTypedList(_len ~/ 4);
  }

  Uint64List asUint64List() {
    return ptr.cast<Uint64>().asTypedList(_len ~/ 8);
  }

  Int8List asInt8List() {
    return ptr.cast<Int8>().asTypedList(_len);
  }

  Int16List asInt16List() {
    return ptr.cast<Int16>().asTypedList(_len ~/ 2);
  }

  Int32List asInt32List() {
    return ptr.cast<Int32>().asTypedList(_len ~/ 4);
  }

  Int64List asInt64List() {
    return ptr.cast<Int64>().asTypedList(_len ~/ 8);
  }

  Float32List asFloat32List() {
    return ptr.cast<Float>().asTypedList(_len ~/ 4);
  }

  Float64List asFloat64List() {
    return ptr.cast<Double>().asTypedList(_len ~/ 8);
  }

  @override
  int get len => _len;
}

class EmptyMmapInner implements MmapInner {
  @override
  Uint8List asBytes() => Uint8List(0);

  @override
  Float32List asFloat32List() => Float32List(0);

  @override
  Float64List asFloat64List() => Float64List(0);

  @override
  Int16List asInt16List() => Int16List(0);

  @override
  Int32List asInt32List() => Int32List(0);

  @override
  Int64List asInt64List() => Int64List(0);

  @override
  Int8List asInt8List() => Int8List(0);

  @override
  Uint16List asUint16List() => Uint16List(0);

  @override
  Uint32List asUint32List() => Uint32List(0);

  @override
  Uint64List asUint64List() => Uint64List(0);

  @override
  Uint8List asUint8List() => Uint8List(0);

  @override
  void drop() {}

  @override
  int get len => 0;

  @override
  Pointer<Void> get ptr => nullptr;
}

abstract class MmapInner {
  factory MmapInner(
      int len, int file_descriptor, int prot, int flags, int offset) {
    if (len == 0) {
      return EmptyMmapInner();
    } else {
      return MmapInnerImpl._(len, file_descriptor, prot, flags, offset);
    }
  }

  int get len;

  Uint8List asBytes();

  Float32List asFloat32List();

  Float64List asFloat64List();

  Int16List asInt16List();

  Int32List asInt32List();

  Int64List asInt64List();

  Int8List asInt8List();

  Uint16List asUint16List();

  Uint32List asUint32List();

  Uint64List asUint64List();

  Uint8List asUint8List();

  void drop();

  Pointer<Void> get ptr;
}
