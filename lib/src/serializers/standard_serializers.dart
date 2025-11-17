// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_lang/lang.dart';
import '../base.dart';

/// {@template jetleaf_string_serializer}
/// A **standard JSON serializer** for converting Dart [String] values into JSON string literals.
///
/// This serializer writes the provided [String] directly to the JSON output
/// as a quoted value using [JsonGenerator.writeString].  
/// It ensures proper escaping of special characters and compliance with JSON
/// encoding rules.
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = StringSerializer();
///
/// serializer.serialize("hello", generator, SerializerProvider());
/// print(generator.toString()); // "hello"
/// ```
///
/// ### Behavior Overview
/// | Input Dart Value | JSON Output | Description |
/// |-------------------|-------------|--------------|
/// | `"hello"` | `"hello"` | Standard string encoding |
/// | `""` | `""` | Empty string |
///
/// ### Design Notes
/// - Escapes all control and special characters per JSON specification.
/// - Null-safety is handled externally — the serializer assumes non-null input.
/// - Serves as the foundation for higher-level serializers handling
///   string-based identifiers or labels.
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [IntSerializer]
/// {@endtemplate}
final class StringSerializer implements JsonSerializer<String> {
  /// {@macro jetleaf_string_serializer}
  const StringSerializer();

  @override
  bool canSerialize(Class type) => type == Class<String>() || type.getType() == String;

  @override
  void serialize(String value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeString(value);
  }

  @override
  Class<String> toClass() => Class<String>(null, PackageNames.DART);
}

/// {@template jetleaf_int_serializer}
/// A **standard JSON serializer** for encoding Dart [int] values as JSON numeric literals.
///
/// This serializer writes an integer directly to the JSON output without
/// quotes, ensuring type preservation in the generated JSON.
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = IntSerializer();
///
/// serializer.serialize(42, generator, SerializerProvider());
/// print(generator.toString()); // 42
/// ```
///
/// ### Behavior Overview
/// | Input Dart Value | JSON Output | Description |
/// |-------------------|-------------|--------------|
/// | `42` | `42` | Numeric encoding |
/// | `0` | `0` | Zero preserved |
///
/// ### Design Notes
/// - Does **not** perform number formatting — writes raw integer value.
/// - Null-safety and range validation are handled by the surrounding framework.
/// - Forms the core numeric serializer used in Jetleaf’s default provider registry.
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [DoubleSerializer]
/// {@endtemplate}
final class IntSerializer implements JsonSerializer<int> {
  /// {@macro jetleaf_int_serializer}
  const IntSerializer();

  @override
  bool canSerialize(Class type) => type == Class<int>() || type.getType() == int;

  @override
  void serialize(int value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeNumber(value);
  }

  @override
  Class<int> toClass() => Class<int>(null, PackageNames.DART);
}

/// {@template jetleaf_double_serializer}
/// A **standard JSON serializer** for Dart [double] values, converting
/// them into JSON numeric literals with fractional precision.
///
/// This serializer writes the double directly to the JSON output stream
/// using [JsonGenerator.writeNumber], ensuring proper numeric encoding
/// without quoting.
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = DoubleSerializer();
///
/// serializer.serialize(3.14159, generator, SerializerProvider());
/// print(generator.toString()); // 3.14159
/// ```
///
/// ### Behavior Overview
/// | Input Dart Value | JSON Output | Description |
/// |-------------------|-------------|--------------|
/// | `3.14159` | `3.14159` | Standard double encoding |
/// | `0.0` | `0.0` | Zero value preserved |
/// | `double.nan` | `"NaN"` | May be represented as a string depending on generator |
///
/// ### Design Notes
/// - Writes doubles as raw numbers (not strings).
/// - Delegates precision and formatting control to the [JsonGenerator].
/// - Typically used by higher-level serializers (e.g., for timestamps or ratios).
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [NumSerializer]
/// {@endtemplate}
final class DoubleSerializer implements JsonSerializer<double> {
  /// {@macro jetleaf_double_serializer}
  const DoubleSerializer();

  @override
  bool canSerialize(Class type) => type == Class<double>() || type.getType() == double;

  @override
  void serialize(double value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeNumber(value);
  }

  @override
  Class<double> toClass() => Class<double>(null, PackageNames.DART);
}

/// {@template jetleaf_num_serializer}
/// A **standard JSON serializer** for Dart [num] values, supporting both
/// [int] and [double] types during serialization.
///
/// This serializer is a polymorphic numeric encoder capable of writing
/// integers and floating-point numbers as valid JSON numbers.
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = NumSerializer();
///
/// serializer.serialize(10, generator, SerializerProvider());
/// serializer.serialize(2.718, generator, SerializerProvider());
/// ```
///
/// ### Behavior Overview
/// | Input Dart Value | JSON Output | Description |
/// |-------------------|-------------|--------------|
/// | `10` | `10` | Integer form |
/// | `2.718` | `2.718` | Floating-point form |
/// | `0` | `0` | Zero preserved |
///
/// ### Design Notes
/// - Provides flexibility for numeric fields that may vary in type.
/// - Delegates precision handling to [JsonGenerator].
/// - Useful in deserialization scenarios where JSON number type is ambiguous.
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [DoubleSerializer]
/// {@endtemplate}
final class NumSerializer implements JsonSerializer<num> {
  /// {@macro jetleaf_num_serializer}
  const NumSerializer();

  @override
  bool canSerialize(Class type) => type == Class<num>() || type.getType() == num;

  @override
  void serialize(num value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeNumber(value);
  }

  @override
  Class<num> toClass() => Class<num>(null, PackageNames.DART);
}

/// {@template jetleaf_bool_serializer}
/// A **standard JSON serializer** for Dart [bool] values, encoding them as
/// JSON literals `true` or `false`.
///
/// This serializer ensures that boolean values are written in a JSON-compliant
/// form using [JsonGenerator.writeBoolean].
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = BoolSerializer();
///
/// serializer.serialize(true, generator, SerializerProvider());
/// print(generator.toString()); // true
/// ```
///
/// ### Behavior Overview
/// | Dart Value | JSON Output | Description |
/// |-------------|-------------|--------------|
/// | `true` | `true` | Boolean literal |
/// | `false` | `false` | Boolean literal |
///
/// ### Design Notes
/// - Writes `true` and `false` as raw JSON tokens (not strings).
/// - Used as a primitive serializer in collections, maps, and POJOs.
/// - Complies with [RFC 8259](https://www.rfc-editor.org/rfc/rfc8259) JSON rules.
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [BoolDeserializer]
/// {@endtemplate}
final class BoolSerializer implements JsonSerializer<bool> {
  /// {@macro jetleaf_bool_serializer}
  const BoolSerializer();

  @override
  bool canSerialize(Class type) => type == Class<bool>() || type.getType() == bool;

  @override
  void serialize(bool value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeBoolean(value);
  }

  @override
  Class<bool> toClass() => Class<bool>(null, PackageNames.DART);
}

/// {@template jetleaf_list_serializer}
/// A **standard JSON serializer** for Dart [List] values, encoding them as
/// JSON arrays.
///
/// The serializer writes each element of the list sequentially using
/// the configured [SerializerProvider] to delegate serialization of
/// nested types.
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = ListSerializer();
///
/// serializer.serialize([1, "two", true], generator, SerializerProvider());
/// print(generator.toString()); // [1,"two",true]
/// ```
///
/// ### Behavior Overview
/// | Dart Input | JSON Output | Description |
/// |-------------|-------------|--------------|
/// | `[]` | `[]` | Empty list |
/// | `[1, 2, 3]` | `[1,2,3]` | Homogeneous list |
/// | `[1, "a", true]` | `[1,"a",true]` | Heterogeneous list |
///
/// ### Design Notes
/// - Starts and ends with `[` and `]` tokens.
/// - Uses recursive serialization for list elements.
/// - Throws a [FormatException] if list items cannot be serialized.
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [ListDeserializer]
/// - [MapSerializer]
/// {@endtemplate}
final class ListSerializer implements JsonSerializer<List> {
  /// {@macro jetleaf_list_serializer}
  const ListSerializer();

  @override
  bool canSerialize(Class type) => type == Class<List>() || type.getType() == List;

  @override
  void serialize(List value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeStartArray();
    for (final item in value) {
      serializer.serialize(item, generator);
    }
    generator.writeEndArray();
  }

  @override
  Class<List> toClass() => Class<List>(null, PackageNames.DART);
}

/// {@template jetleaf_set_serializer}
/// A **standard JSON serializer** for Dart [Set] values, encoding them as
/// JSON arrays.
///
/// Since JSON does not have a native “set” type, this serializer converts
/// a [Set] into an array while preserving element order (iteration order).
///
/// Each element is serialized recursively using the provided
/// [SerializerProvider].
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = SetSerializer();
///
/// serializer.serialize({'apple', 'banana', 'cherry'}, generator, SerializerProvider());
/// print(generator.toString()); // ["apple","banana","cherry"]
/// ```
///
/// ### Behavior Overview
/// | Dart Input | JSON Output | Description |
/// |-------------|-------------|--------------|
/// | `{}` | `[]` | Empty set |
/// | `{"a", "b"}` | `["a","b"]` | String set |
/// | `{1, true}` | `[1,true]` | Heterogeneous set |
///
/// ### Design Notes
/// - Represented as a JSON array for compatibility.
/// - Maintains iteration order of the [Set].
/// - Delegates serialization of nested types to the [SerializerProvider].
/// - Throws [FormatException] if an element cannot be serialized.
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [SetDeserializer]
/// - [ListSerializer]
/// {@endtemplate}
final class SetSerializer implements JsonSerializer<Set> {
  /// {@macro jetleaf_set_serializer}
  const SetSerializer();

  @override
  bool canSerialize(Class type) => type == Class<Set>() || type.getType() == Set;

  @override
  void serialize(Set value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeStartArray();
    for (final item in value) {
      serializer.serialize(item, generator);
    }
    generator.writeEndArray();
  }

  @override
  Class<Set> toClass() => Class<Set>(null, PackageNames.DART);
}

/// {@template jetleaf_map_serializer}
/// A **standard JSON serializer** for Dart [Map] values, encoding them as
/// JSON objects with string keys.
///
/// Keys are converted to JSON field names using the configured
/// [NamingStrategy] from the [SerializerProvider].  
/// Values are serialized recursively according to their runtime types.
///
/// ### Usage Example
/// ```dart
/// final generator = JsonGenerator();
/// const serializer = MapSerializer();
///
/// serializer.serialize({
///   "name": "Alice",
///   "age": 30,
///   "active": true,
/// }, generator, SerializerProvider());
///
/// print(generator.toString()); // {"name":"Alice","age":30,"active":true}
/// ```
///
/// ### Behavior Overview
/// | Dart Input | JSON Output | Description |
/// |-------------|-------------|--------------|
/// | `{}` | `{}` | Empty map |
/// | `{"a":1}` | `{"a":1}` | Simple key-value |
/// | `{"x": [1,2]}` | `{"x":[1,2]}` | Nested structure |
///
/// ### Design Notes
/// - Converts all keys to strings (JSON object keys must be strings).  
/// - Delegates field naming to the [NamingStrategy].  
/// - Uses recursive serialization for map values.  
/// - Throws [FormatException] if non-serializable values are encountered.  
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonGenerator]
/// - [MapDeserializer]
/// - [NamingStrategy]
/// {@endtemplate}
final class MapSerializer implements JsonSerializer<Map> {
  /// {@macro jetleaf_map_serializer}
  const MapSerializer();

  @override
  bool canSerialize(Class type) => type == Class<Map>() || type.getType() == Map;

  @override
  void serialize(Map value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeStartObject();
    final naming = serializer.getNamingStrategy();

    for (final entry in value.entries) {
      final key = entry.key.toString();
      final jsonKey = naming.toJsonName(key);
      generator.writeFieldName(jsonKey);
      serializer.serialize(entry.value, generator);
    }

    generator.writeEndObject();
  }

  @override
  Class<Map> toClass() => Class<Map>(null, PackageNames.DART);
}