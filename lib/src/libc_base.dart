import 'dart:ffi';
import 'package:ffi/ffi.dart';

final DynamicLibrary stdlib = DynamicLibrary.process();

typedef LibcAbsNative = Int32 Function(Int32);
typedef LibcAbs = int Function(int);
final LibcAbs libcAbs = stdlib.lookupFunction<LibcAbsNative, LibcAbs>('abs');

typedef Mmap64Native = Pointer<Void> Function(
    Pointer<Void>, Uint64, Int32, Int32, Int32, Uint64);
typedef Mmap64 = Pointer<Void> Function(Pointer<Void>, int, int, int, int, int);
final Mmap64 mmap = stdlib.lookupFunction<Mmap64Native, Mmap64>('mmap');

typedef MunmapNative = Int32 Function(Pointer<Void>, Uint64);
typedef Munmap = int Function(Pointer<Void>, int);
final Munmap _munmap = stdlib.lookupFunction<MunmapNative, Munmap>('munmap');

typedef OpenNative = Int32 Function(Pointer<Utf8>, Int32, Int32);
typedef Open = int Function(Pointer<Utf8>, int, int);
final Open _open = stdlib.lookupFunction<OpenNative, Open>('open');

typedef CloseNative = Int32 Function(Int32);
typedef Close = int Function(int);
final Close _close = stdlib.lookupFunction<CloseNative, Close>('close');

typedef SysconfNative = Int64 Function(Int32);
typedef Sysconf = int Function(int);
final Sysconf sysconf =
    stdlib.lookupFunction<SysconfNative, Sysconf>('sysconf');

typedef StrerrorNative = Pointer<Utf8> Function(Int32);
typedef Strerror = Pointer<Utf8> Function(int);
final Strerror _strerror =
    stdlib.lookupFunction<StrerrorNative, Strerror>('strerror');

final errno = stdlib.lookup<Int32>('errno');

String strerror(int errno) {
  final error = _strerror(errno);
  if (error.address == 0) {
    return 'Unknown error';
  }
  return error.toDartString();
}

String lastError() {
  return strerror(errno.value);
}

const _SC_PAGESIZE = 30;

int pageSize() {
  return sysconf(_SC_PAGESIZE);
}

int open(String path, int flags, int mode) {
  final cPath = path.toNativeUtf8(allocator: malloc);
  final result = _open(cPath, flags, mode);
  malloc.free(cPath);

  if (result < 0) {
    throw Exception('open : ${lastError()} : $path');
  }
  return result;
}

void close(int fd) {
  final result = _close(fd);
  if (result < 0) {
    throw Exception('close : ${lastError()} : ${fd}');
  }
}

void munmap(Pointer<Void> addr, int len) {
  final result = _munmap(addr, len);
  if (result != 0) {
    throw Exception('munmap : ${lastError()}');
  }
}
