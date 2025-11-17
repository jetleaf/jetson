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

import '../annotations.dart';
import '../base.dart';

/// {@template jetleaf_dart_serializer}
/// A **reflection-based JSON serializer** for arbitrary Dart objects.
///
/// This serializer uses [Class] metadata to dynamically inspect and
/// convert Dart objects into JSON representations.  
/// It supports annotations such as [JsonField], [JsonIgnore],
/// and [JsonConverter] to fine-tune the serialization process.
///
/// ### Core Features
/// - Reflective serialization of all accessible fields.
/// - Honors `toJson()` methods if present on the target type.
/// - Skips `null` values if `SerializationFeature.WRITE_NULL_MAP_VALUES` is disabled.
/// - Integrates with custom field-level [JsonConverter]s and naming strategies.
/// - Ignores fields annotated with [JsonIgnore].
///
/// ### Usage Example
/// ```dart
/// @JsonSerializable()
/// class Person {
///   final String name;
///   final int age;
///
///   Person(this.name, this.age);
/// }
///
/// final person = Person("Alice", 30);
/// final serializer = DartSerializer(Class<Person>(Person, "Person"));
///
/// final generator = JsonGenerator();
/// serializer.serialize(person, generator, SerializerProvider());
/// print(generator.toString()); // {"name":"Alice","age":30}
/// ```
///
/// ### Behavior Overview
/// | Behavior | Description |
/// |-----------|--------------|
/// | `toJson()` present | Invoked directly if parameterless |
/// | `@JsonIgnore` | Field skipped entirely |
/// | `@JsonField(name: "alias")` | Custom field name applied |
/// | `@JsonConverter` | Field serialized using custom converter |
/// | `null` values | Skipped if feature disabled |
///
/// ### Design Notes
/// - Designed as the fallback serializer for unknown or complex Dart types.  
/// - Prioritizes explicit control via annotations before reflection.  
/// - Avoids recursive self-serialization to prevent infinite loops.  
/// - Type-safe and compatible with Jetleaf’s [JsonMapper] pipeline.  
///
/// ### See Also
/// - [JsonSerializer]
/// - [JsonConverter]
/// - [SerializationFeature]
/// - [NamingStrategy]
/// - [JsonField]
/// {@endtemplate}
final class DartSerializer implements JsonSerializer<Object> {
  /// The reflected [Class] metadata for the target Dart type.
  final Class _type;

  /// Creates a new [DartSerializer] for the given [Class] type.
  ///
  /// {@macro jetleaf_dart_serializer}
  DartSerializer(this._type);

  @override
  bool canSerialize(Class type) => type == _type;

  @override
  void serialize(Object value, JsonGenerator generator, SerializerProvider serializer) {
    final type = value.getClass();
    final namingStrategy = serializer.getNamingStrategy();
    final allowNullValues = serializer.getObjectMapper().isFeatureEnabled(SerializationFeature.WRITE_NULL_MAP_VALUES.name);

    // 1. Prefer custom `toJson()` method if defined
    final toJsonMethodIfAvailable = type.getMethod("toJson");
    if (toJsonMethodIfAvailable != null && toJsonMethodIfAvailable.getParameterCount() == 0) {
      serializer.serialize(toJsonMethodIfAvailable.invoke(value), generator);
      return;
    }

    // 2. Check for [ToJson] annotation
    final toJson = type.getDirectAnnotation<ToJson>();
    if (toJson != null) {
      serializer.serialize(toJson.creator(value), generator);
      return;
    }

    generator.writeStartObject();

    // 3. Reflect over fields
    for (final field in type.getFields()) {
      // Skip ignored fields
      if (field.hasDirectAnnotation<JsonIgnore>()) continue;

      final jsonField = field.getDirectAnnotation<JsonField>();
      if (jsonField != null && jsonField.ignore) continue;

      final fieldName = field.getName();
      final fieldValue = field.getValue(value);

      // Skip nulls if not allowed
      if (fieldValue == null && !allowNullValues) continue;

      // Determine final JSON field name
      final jsonFieldName = jsonField?.name ?? namingStrategy.toJsonName(fieldName);

      // Handle field-level converter
      final converterAnn = field.getDirectAnnotation<JsonConverter>();
      if (converterAnn != null) {
        final converterInstance = converterAnn.converter;
        final ct = converterAnn.type;

        final adapter = ct != null ? ct.toClass().getNoArgConstructor()?.newInstance() : converterInstance;

        if (adapter is JsonSerializer) {
          generator.writeFieldName(jsonFieldName);
          adapter.serialize(fieldValue, generator, serializer);
          continue; // handled by converter
        }
      }

      // Use appropriate serializer for field type
      final possibleSerializer = serializer.findSerializerForType(field.getReturnClass());
      if (possibleSerializer != null) {
        generator.writeFieldName(jsonFieldName);
        possibleSerializer.serialize(fieldValue, generator, serializer);
        continue;
      }

      // Default serialization path
      generator.writeFieldName(jsonFieldName);
      serializer.serialize(fieldValue, generator);
    }

    generator.writeEndObject();
  }

  @override
  Class<Object> toClass() => Class.fromQualifiedName(_type.getQualifiedName());
}