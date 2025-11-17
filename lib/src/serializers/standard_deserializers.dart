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

/// {@template jetleaf_string_deserializer}
/// A **standard JSON deserializer** for converting values into Dart [String] instances.
///
/// This deserializer handles generic JSON string tokens and safely converts
/// the current JSON value into its string representation.  
/// It is a minimal, stateless implementation designed for use within
/// Jetleaf’s serialization and deserialization pipeline.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('"hello"');
/// final deserializer = const StringDeserializer();
/// final result = deserializer.deserialize(parser, ctxt);
///
/// print(result); // "hello"
/// ```
///
/// ### Behavior Overview
/// | Input Value | Output | Description |
/// |--------------|---------|--------------|
/// | `"hello"` | `"hello"` | Simple string passthrough |
/// | `123` | `"123"` | Converts numeric value to string |
/// | `true` | `"true"` | Converts boolean to string |
/// | `null` | `null` | Returns `null` safely |
///
/// ### Design Notes
/// - Always returns a [String] or `null` (never throws for type mismatch).
/// - Intended for generic JSON token deserialization, not for strict schema binding.
/// - Optimized for simplicity and consistency with other Jetleaf primitive deserializers.
///
/// ### See Also
/// - [IntDeserializer]
/// - [JsonDeserializer]
/// - [JsonParser]
/// {@endtemplate}
final class StringDeserializer implements JsonDeserializer<String> {
  /// {@macro jetleaf_string_deserializer}
  const StringDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<String>() || type.getType() == String;

  @override
  String? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final value = parser.getCurrentValue();
    if (value == null) return null;
    return value.toString();
  }

  @override
  Class<String> toClass() => Class<String>(null, PackageNames.DART);
}

/// {@template jetleaf_int_deserializer}
/// A **standard JSON deserializer** for converting values into Dart [int] instances.
///
/// This deserializer supports multiple numeric representations, including
/// integers, numeric strings, and generic `num` values.  
/// It provides safe type coercion and null handling consistent with the
/// Jetleaf deserialization framework.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('42');
/// final deserializer = const IntDeserializer();
/// final result = deserializer.deserialize(parser, ctxt);
///
/// print(result); // 42
/// ```
///
/// ### Behavior Overview
/// | Input Value | Output | Description |
/// |--------------|---------|--------------|
/// | `42` | `42` | Direct integer passthrough |
/// | `42.9` | `42` | Coerced to integer via `toInt()` |
/// | `"123"` | `123` | Parsed from string |
/// | `"abc"` | `null` | Invalid parse, returns `null` |
/// | `null` | `null` | Returns `null` safely |
///
/// ### Design Notes
/// - Performs safe conversions without throwing on invalid types.
/// - Consistent with Dart’s [int.tryParse] semantics for resilience.
/// - Ideal for schema-flexible APIs or relaxed JSON payloads.
///
/// ### See Also
/// - [StringDeserializer]
/// - [JsonDeserializer]
/// - [JsonParser]
/// {@endtemplate}
final class IntDeserializer implements JsonDeserializer<int> {
  /// {@macro jetleaf_int_deserializer}
  const IntDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<int>() || type.getType() == int;

  @override
  int? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final value = parser.getCurrentValue();
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  Class<int> toClass() => Class<int>(null, PackageNames.DART);
}

/// {@template jetleaf_double_deserializer}
/// A **standard JSON deserializer** for converting values into Dart [double] instances.
///
/// This deserializer provides safe, loss-tolerant conversion from JSON numeric
/// or string representations into a floating-point value.  
/// It supports all numeric primitives and gracefully handles invalid or null
/// input without throwing.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('3.1415');
/// final deserializer = const DoubleDeserializer();
/// final result = deserializer.deserialize(parser, ctxt);
///
/// print(result); // 3.1415
/// ```
///
/// ### Behavior Overview
/// | Input Value | Output | Description |
/// |--------------|---------|--------------|
/// | `3.14` | `3.14` | Direct double passthrough |
/// | `42` | `42.0` | Converts int to double |
/// | `"2.718"` | `2.718` | Parses numeric string |
/// | `"abc"` | `null` | Invalid numeric parse |
/// | `null` | `null` | Returns `null` safely |
///
/// ### Design Notes
/// - Never throws on invalid numeric formats — uses [double.tryParse].
/// - Converts any [num] to [double] via [num.toDouble].
/// - Intended for flexible schema and tolerant deserialization pipelines.
/// - Precision is determined by the platform IEEE 754 double implementation.
///
/// ### See Also
/// - [NumDeserializer]
/// - [IntDeserializer]
/// - [StringDeserializer]
/// - [JsonDeserializer]
/// {@endtemplate}
final class DoubleDeserializer implements JsonDeserializer<double> {
  /// {@macro jetleaf_double_deserializer}
  const DoubleDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<double>() || type.getType() == double;

  @override
  double? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final value = parser.getCurrentValue();
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  Class<double> toClass() => Class<double>(null, PackageNames.DART);
}

/// {@template jetleaf_num_deserializer}
/// A **standard JSON deserializer** for general [num] values.
///
/// This deserializer handles both integer and floating-point representations,
/// returning the most appropriate numeric type for the given input.  
/// It is ideal for schema-flexible JSON payloads or when number precision
/// type (int vs double) is not predetermined.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('123.456');
/// final deserializer = const NumDeserializer();
/// final result = deserializer.deserialize(parser, ctxt);
///
/// print(result); // 123.456
/// ```
///
/// ### Behavior Overview
/// | Input Value | Output | Description |
/// |--------------|---------|--------------|
/// | `42` | `42` | Returns int as-is |
/// | `3.14` | `3.14` | Returns double as-is |
/// | `"7"` | `7` | Parses integer string |
/// | `"8.9"` | `8.9` | Parses floating-point string |
/// | `"abc"` | `null` | Invalid numeric parse |
/// | `null` | `null` | Returns `null` safely |
///
/// ### Design Notes
/// - Uses [num.tryParse] for robust numeric coercion.
/// - Returns either [int] or [double] depending on parse result.
/// - Best suited for JSON structures with mixed numeric representations.
/// - Provides consistent, non-throwing numeric deserialization semantics.
///
/// ### See Also
/// - [DoubleDeserializer]
/// - [IntDeserializer]
/// - [JsonDeserializer]
/// {@endtemplate}
final class NumDeserializer implements JsonDeserializer<num> {
  /// {@macro jetleaf_num_deserializer}
  const NumDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<num>() || type.getType() == num;

  @override
  num? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final value = parser.getCurrentValue();
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  @override
  Class<num> toClass() => Class<num>(null, PackageNames.DART);
}

/// {@template jetleaf_bool_deserializer}
/// A **standard JSON deserializer** for converting values into Dart [bool] instances.
///
/// This deserializer converts common JSON boolean values, such as `true`, `false`,
/// and string representations (`"true"`, `"false"`), into native Dart [bool] values.
///
/// It is designed to be **forgiving** — treating any non-null, non-"true" value as `false`,
/// while still maintaining strong typing in the deserialization process.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('true');
/// final deserializer = const BoolDeserializer();
/// final result = deserializer.deserialize(parser, ctxt);
///
/// print(result); // true
/// ```
///
/// ### Behavior Overview
/// | Input Value | Output | Description |
/// |--------------|---------|--------------|
/// | `true` | `true` | Direct boolean passthrough |
/// | `false` | `false` | Direct boolean passthrough |
/// | `"true"` | `true` | String converted to boolean |
/// | `"false"` | `false` | String converted to boolean |
/// | `"yes"` | `false` | Unrecognized string defaults to false |
/// | `null` | `null` | Returns `null` safely |
///
/// ### Design Notes
/// - Supports both native and string-based JSON boolean representations.
/// - Non-boolean and non-string inputs are treated as `false`.
/// - Intentionally tolerant for flexible JSON schemas (e.g., APIs returning strings for booleans).
/// - Non-throwing conversion semantics for safety in mixed-type payloads.
///
/// ### See Also
/// - [StringDeserializer]
/// - [JsonDeserializer]
/// - [DeserializationContext]
/// {@endtemplate}
final class BoolDeserializer implements JsonDeserializer<bool> {
  /// {@macro jetleaf_bool_deserializer}
  const BoolDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<bool>() || type.getType() == bool;

  @override
  bool? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final value = parser.getCurrentValue();
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  @override
  Class<bool> toClass() => Class<bool>(null, PackageNames.DART);
}

/// {@template jetleaf_list_deserializer}
/// A **standard JSON deserializer** for deserializing JSON arrays into Dart [List] objects.
///
/// This deserializer reads a sequence of JSON values enclosed in brackets (`[...]`)
/// and returns a mutable [List] containing the corresponding Dart objects.  
/// It performs a shallow parse — each element is deserialized as-is from
/// the parser’s current token value.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('[1, "two", true]');
/// final deserializer = const ListDeserializer();
/// final result = deserializer.deserialize(parser, ctxt);
///
/// print(result); // [1, "two", true]
/// ```
///
/// ### Behavior Overview
/// | Input JSON | Output Dart Value | Description |
/// |-------------|------------------|--------------|
/// | `[1, 2, 3]` | `[1, 2, 3]` | Numeric array |
/// | `["a", "b"]` | `["a", "b"]` | String array |
/// | `[true, false]` | `[true, false]` | Boolean array |
/// | `[]` | `[]` | Empty array |
/// | `null` | `null` | Safe null passthrough |
///
/// ### Design Notes
/// - Validates that the current token is [JsonToken.START_ARRAY]; otherwise throws [FormatException].
/// - Returns a dynamic [List<Object?>] to allow mixed-type collections.
/// - Does **not** recursively deserialize nested objects — higher-level
///   [JsonDeserializer]s should handle typed element deserialization.
/// - Designed for efficiency and interoperability with JSON parsing pipelines.
///
/// ### See Also
/// - [MapDeserializer]
/// - [JsonParser]
/// - [JsonToken]
/// {@endtemplate}
final class ListDeserializer implements JsonDeserializer<List> {
  /// {@macro jetleaf_list_deserializer}
  const ListDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<List>() || type.getType() == List;

  @override
  List? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final token = parser.getCurrentToken();
    
    if (token == JsonToken.VALUE_NULL) {
      return null;
    }

    if (token != JsonToken.START_ARRAY) {
      throw FormatException('Expected START_ARRAY, got $token');
    }

    final list = <Object>[];

    while (parser.nextToken()) {
      final currentToken = parser.getCurrentToken();

      if (currentToken == JsonToken.END_ARRAY) {
        break;
      }

      // Handle nested containers specially: if the element is an object/array,
      // delegate to the context so the appropriate deserializer can consume
      // the entire nested structure from the parser.
      if (currentToken == JsonToken.START_OBJECT || currentToken == JsonToken.START_ARRAY) {
        final elementType = toClass.componentType() ?? Class.forType(Object);
        final result = ctxt.deserialize(parser, elementType);

        list.add(result);
        continue;
      }

      if (currentToken == JsonToken.VALUE_NULL) {
        continue;
      }

      // Primitive/scalar values: try to resolve deserializer either from the
      // declared component type or from the runtime value's class.
      final value = parser.getCurrentValue();
      if (value == null) {
        // Nothing to do for unexpected nulls; push null and continue.
        continue;
      }

      final componentType = toClass.componentType();
      if (componentType != null) {
        final deserializer = ctxt.findDeserializerForType(componentType);
        if (deserializer != null) {
          final result = deserializer.deserialize(parser, ctxt, componentType);
          
          list.add(result);
          continue;
        }
      }

      // Fallback: resolve deserializer by runtime value class
      final valueClass = value.getClass();
      final deserializer = ctxt.findDeserializerForType(valueClass);
      if (deserializer != null) {
        final result = deserializer.deserialize(parser, ctxt, valueClass);
        
        list.add(result);
        continue;
      }

      // If no deserializer found, add raw value
      list.add(value);
    }

    return list;
  }

  @override
  Class<List> toClass() => Class<List>(null, PackageNames.DART);
}

/// {@template jetleaf_map_deserializer}
/// A **standard JSON deserializer** for converting JSON objects into Dart [Map] instances.
///
/// This deserializer reads a sequence of key–value pairs enclosed in braces (`{}`),
/// producing a mutable [Map<String, Object?>] representation.  
/// Each JSON key is automatically transformed according to the active
/// [NamingStrategy] provided by the [DeserializationContext].
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('{"first_name": "Alice", "age": 30}');
/// final deserializer = const MapDeserializer();
/// final context = DeserializationContext.defaultContext();
///
/// final result = deserializer.deserialize(parser, context);
/// print(result); // {firstName: "Alice", age: 30}
/// ```
///
/// ### Behavior Overview
/// | Input JSON | Output Dart Map | Description |
/// |-------------|-----------------|--------------|
/// | `{ "a": 1, "b": 2 }` | `{ "a": 1, "b": 2 }` | Simple key–value pairs |
/// | `{}` | `{}` | Empty object |
/// | `null` | `null` | Safe null passthrough |
///
/// ### Design Notes
/// - Applies the active [NamingStrategy] (e.g., snake_case → camelCase) to keys.
/// - Produces a shallow map — nested objects are not recursively deserialized.
/// - Non-object tokens cause a [FormatException].
/// - Intended for use as a foundational deserializer in composite models.
///
/// ### See Also
/// - [NamingStrategy]
/// - [JsonDeserializer]
/// - [DeserializationContext]
/// {@endtemplate}
final class MapDeserializer implements JsonDeserializer<Map> {
  /// {@macro jetleaf_map_deserializer}
  const MapDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<Map>() || type.getType() == Map;

  @override
  Map? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final token = parser.getCurrentToken();

    if (token == JsonToken.VALUE_NULL) {
      return null;
    }

    if (token != JsonToken.START_OBJECT) {
      throw FormatException('Expected START_OBJECT, got $token');
    }

    final map = <String, Object>{};
    final naming = ctxt.getNamingStrategy();

    while (parser.nextToken()) {
      final currentToken = parser.getCurrentToken();

      if (currentToken == JsonToken.END_OBJECT) {
        break;
      }

      if (currentToken == JsonToken.FIELD_NAME) {
        final jsonKey = parser.getCurrentName()!;
        final dartKey = naming.toDartName(jsonKey);

        parser.nextToken();
        final currentValueToken = parser.getCurrentToken();

        // If the value is a nested object/array, delegate to context so the
        // appropriate deserializer can consume it entirely.
        if (currentValueToken == JsonToken.START_OBJECT || currentValueToken == JsonToken.START_ARRAY) {
          final valueType = toClass.componentType() ?? Class.forType(Object);
          final result = ctxt.deserialize(parser, valueType);
          map[dartKey] = result;

          continue;
        }

        if (currentValueToken == JsonToken.VALUE_NULL) {
          continue;
        }

        final value = parser.getCurrentValue();
        if (value == null) {
          continue;
        }


        // Try to use the declared map value component type first
        final valueType = toClass.componentType();
        if (valueType != null) {
          final valueDeserializer = ctxt.findDeserializerForType(valueType);
          if (valueDeserializer != null) {
            final deserialized = valueDeserializer.deserialize(parser, ctxt, valueType);
            map[dartKey] = deserialized;

            continue;
          }
        }

        // Fallback to runtime value's deserializer
        final valueClass = value.getClass();
        final deserializer = ctxt.findDeserializerForType(valueClass);
        if (deserializer != null) {
          final result = deserializer.deserialize(parser, ctxt, valueClass);
          map[dartKey] = result;
          
          continue;
        }

        // If nothing else, put raw value
        map[dartKey] = value;
      }
    }

    return map;
  }

  @override
  Class<Map> toClass() => Class<Map>(null, PackageNames.DART);
}

/// {@template jetleaf_set_deserializer}
/// A **standard JSON deserializer** for parsing JSON arrays into Dart [Set] collections.
///
/// This deserializer reads values within a JSON array (`[...]`) and constructs
/// a [Set<Object?>] from the elements. Duplicate values are automatically
/// removed, ensuring uniqueness according to Dart’s equality semantics.
///
/// ### Usage Example
/// ```dart
/// final parser = JsonParser('["apple", "banana", "apple"]');
/// final deserializer = const SetDeserializer();
///
/// final result = deserializer.deserialize(parser, ctxt);
/// print(result); // {"apple", "banana"}
/// ```
///
/// ### Behavior Overview
/// | Input JSON | Output Dart Set | Description |
/// |-------------|----------------|--------------|
/// | `[1, 2, 3]` | `{1, 2, 3}` | Simple numeric set |
/// | `["a", "a"]` | `{"a"}` | Duplicates removed |
/// | `[]` | `{}` | Empty collection |
/// | `null` | `null` | Safe null passthrough |
///
/// ### Design Notes
/// - Returns a mutable [Set<Object?>].
/// - Non-array tokens cause a [FormatException].
/// - Shallow deserialization — nested structures are not deeply parsed.
/// - Optimized for high-throughput parsing of unique collections.
///
/// ### See Also
/// - [ListDeserializer]
/// - [JsonDeserializer]
/// - [JsonParser]
/// {@endtemplate}
final class SetDeserializer implements JsonDeserializer<Set> {
  /// {@macro jetleaf_set_deserializer}
  const SetDeserializer();

  @override
  bool canDeserialize(Class type) => type == Class<Set>() || type.getType() == Set;

  @override
  Set? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final token = parser.getCurrentToken();

    if (token == JsonToken.VALUE_NULL) {
      return null;
    }

    if (token != JsonToken.START_ARRAY) {
      throw FormatException('Expected START_ARRAY, got $token');
    }

    final set = <Object>{};

    while (parser.nextToken()) {
      final currentToken = parser.getCurrentToken();

      if (currentToken == JsonToken.END_ARRAY) {
        break;
      }

      // Handle nested containers by delegating to the context
      if (currentToken == JsonToken.START_OBJECT || currentToken == JsonToken.START_ARRAY) {
        final elementType = toClass.componentType() ?? Class.forType(Object);
        final result = ctxt.deserialize(parser, elementType);
        set.add(result);
        continue;
      }

      if (currentToken == JsonToken.VALUE_NULL) {
        continue;
      }

      final value = parser.getCurrentValue();
      if (value == null) {
        continue;
      }

      final componentType = toClass.componentType();
      if (componentType != null) {
        final deserializer = ctxt.findDeserializerForType(componentType);
        if (deserializer != null) {
          final result = deserializer.deserialize(parser, ctxt, componentType);
          set.add(result);
          continue;
        }
      }

      final valueClass = value.getClass();
      final deserializer = ctxt.findDeserializerForType(valueClass);
      if (deserializer != null) {
        final result = deserializer.deserialize(parser, ctxt, valueClass);
        set.add(result);
        continue;
      }

      set.add(value);
    }

    return set;
  }

  @override
  Class<Set> toClass() => Class<Set>(null, PackageNames.DART);
}