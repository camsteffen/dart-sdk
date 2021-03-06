// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file

/// {@category VM}
/// {@nodoc}
library dart.ffi;

part "native_type.dart";
part "annotations.dart";
part "dynamic_library.dart";

/// Allocate [count] elements of type [T] on the C heap with malloc() and return
/// a pointer to the newly allocated memory.
///
/// Note that the memory are uninitialized.
///
/// TODO(dacoharkes): change signature to T allocate<T extends Pointer>() ?
/// This would enable us to allocate structs. However how do we know the size of
/// structs? https://github.com/dart-lang/sdk/issues/35782
external Pointer<T> allocate<T extends NativeType>({int count: 1});

/// Construction from raw value
external T fromAddress<T extends Pointer>(int ptr);

/// number of bytes used by native type T
external int sizeOf<T extends NativeType>();

/// Convert Dart function to a C function pointer, automatically marshalling
/// the arguments and return value
///
/// If an exception is thrown while calling `f()`, the native function will
/// return `exceptionalReturn`, which must be assignable to return type of `f`.
///
/// The returned function address can only be invoked on the mutator (main)
/// thread of the current isolate. It will abort the process if invoked on any
/// other thread.
///
/// The pointer returned will remain alive for the duration of the current
/// isolate's lifetime. After the isolate it was created in is terminated,
/// invoking it from native code will cause undefined behavior.
external Pointer<NativeFunction<T>> fromFunction<T extends Function>(
    @DartRepresentationOf("T") Function f, Object exceptionalReturn);

/// Represents a pointer into the native C memory.
class Pointer<T extends NativeType> extends NativeType {
  const Pointer();

  /// Store a Dart value into this location.
  ///
  /// The [value] is automatically marshalled into its C representation.
  /// Note that ints which do not fit in [T] are truncated and sign extended,
  /// and doubles stored into Pointer<[Float]> lose precision.
  external void store(@DartRepresentationOf("T") Object value);

  /// Load a Dart value from this location.
  ///
  /// The value is automatically unmarshalled from its C representation.
  external R load<@DartRepresentationOf("T") R>();

  /// Access to the raw pointer value.
  external int get address;

  /// Pointer arithmetic (takes element size into account).
  external Pointer<T> elementAt(int index);

  /// Pointer arithmetic (byte offset).
  ///
  /// TODO(dacoharkes): remove this?
  /// https://github.com/dart-lang/sdk/issues/35883
  external Pointer<T> offsetBy(int offsetInBytes);

  /// Cast Pointer<T> to a (subtype of) Pointer<V>.
  external U cast<U extends Pointer>();

  /// Convert to Dart function, automatically marshalling the arguments
  /// and return value.
  ///
  /// Can only be called on [Pointer]<[NativeFunction]>.
  external R asFunction<@DartRepresentationOf("T") R extends Function>();

  /// Free memory on the C heap pointed to by this pointer with free().
  ///
  /// Note that this zeros out the address.
  external void free();

  /// Equality for Pointers only depends on their address.
  bool operator ==(other) {
    if (other == null) return false;
    return address == other.address;
  }

  /// The hash code for a Pointer only depends on its address.
  int get hashCode {
    return address.hashCode;
  }
}
