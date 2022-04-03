import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:memmap/libc.dart' as libc;

class Mmap {
  int _fd;
  MmapInner _inner;

  Mmap(String fileName) {
    final file = File(fileName);
    final stat = file.statSync();
    final size = stat.size;
    _fd = libc.open(fileName, 0, 0);
    _inner = MmapInner(size, _fd, 0);
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

  Pointer<Uint8> asUint8Pointer() {
    return _inner.asUint8Pointer();
  }

  Pointer<Int8> asInt8Pointer() {
    return _inner.asInt8Pointer();
  }

  Pointer<Uint16> asUint16Pointer() {
    return _inner.asUint16Pointer();
  }

  Pointer<Int16> asInt16Pointer() {
    return _inner.asInt16Pointer();
  }

  Pointer<Uint32> asUint32Pointer() {
    return _inner.asUint32Pointer();
  }

  Pointer<Int32> asInt32Pointer() {
    return _inner.asInt32Pointer();
  }

  Pointer<Uint64> asUint64Pointer() {
    return _inner.asUint64Pointer();
  }

  Pointer<Int64> asInt64Pointer() {
    return _inner.asInt64Pointer();
  }

  Pointer<Float> asFloatPointer() {
    return _inner.asFloatPointer();
  }

  Pointer<Double> asDoublePointer() {
    return _inner.asDoublePointer();
  }
}

class MmapInner {
  static const PROT_NONE = 0;
  static const PROT_READ = 1;
  static const PROT_WRITE = 2;
  static const PROT_EXEC = 4;

  static const MAP_FILE = 0x0000;
  static const MAP_SHARED = 0x0001;
  static const MAP_PRIVATE = 0x0002;
  static const MAP_FIXED = 0x0010;

  int ptrAddr;
  int len;

  MmapInner(this.len, int file_descriptor, int offset) {
    ptrAddr = libc
        .mmap(nullptr, len, PROT_READ, MAP_PRIVATE, file_descriptor, offset)
        .address;
  }

  Pointer<Void> get ptr => Pointer.fromAddress(ptrAddr);

  void drop() {
    var alignment = ptr.address % libc.pageSize();
    if (alignment != 0) {
      var alignedPtr = Pointer.fromAddress(ptr.address - alignment);
      libc.munmap(alignedPtr, len + alignment);
    } else {
      libc.munmap(ptr, len);
    }
  }

  Uint8List asBytes() {
    var bytes = ptr.cast<Uint8>();
    return bytes.asTypedList(len);
  }

  int byteAt(int index) {
    var bytes = ptr.cast<Uint8>();
    return bytes[index];
  }

  Uint8List asUint8List() {
    return asUint8Pointer().asTypedList(len);
  }

  Uint16List asUint16List() {
    return asUint16Pointer().asTypedList(len ~/ 2);
  }

  Uint32List asUint32List() {
    return asUint32Pointer().asTypedList(len ~/ 4);
  }

  Uint64List asUint64List() {
    return asUint64Pointer().asTypedList(len ~/ 8);
  }

  Int8List asInt8List() {
    return asInt8Pointer().asTypedList(len);
  }

  Int16List asInt16List() {
    return asInt16Pointer().asTypedList(len ~/ 2);
  }

  Int32List asInt32List() {
    return asInt32Pointer().asTypedList(len ~/ 4);
  }

  Int64List asInt64List() {
    return asInt64Pointer().asTypedList(len ~/ 8);
  }

  Float32List asFloat32List() {
    return asFloatPointer().asTypedList(len ~/ 4);
  }

  Float64List asFloat64List() {
    return asDoublePointer().asTypedList(len ~/ 8);
  }

  Pointer<Uint8> asUint8Pointer() {
    return ptr.cast<Uint8>();
  }

  Pointer<Int8> asInt8Pointer() {
    return ptr.cast<Int8>();
  }

  Pointer<Int16> asInt16Pointer() {
    return ptr.cast<Int16>();
  }

  Pointer<Int32> asInt32Pointer() {
    return ptr.cast<Int32>();
  }

  Pointer<Int64> asInt64Pointer() {
    return ptr.cast<Int64>();
  }

  Pointer<Uint16> asUint16Pointer() {
    return ptr.cast<Uint16>();
  }

  Pointer<Uint32> asUint32Pointer() {
    return ptr.cast<Uint32>();
  }

  Pointer<Uint64> asUint64Pointer() {
    return ptr.cast<Uint64>();
  }

  Pointer<Float> asFloatPointer() {
    return ptr.cast<Float>();
  }

  Pointer<Double> asDoublePointer() {
    return ptr.cast<Double>();
  }
}
