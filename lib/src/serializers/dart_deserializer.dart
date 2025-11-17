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
import '../exceptions.dart';

/// {@template jetleaf_dart_deserializer}
/// A **reflection-based JSON deserializer** for arbitrary Dart objects.
///
/// This deserializer uses [Class] metadata and annotations such as [JsonField],
/// [JsonIgnore], and [JsonConverter] to reconstruct Dart objects from JSON maps.
/// It seamlessly integrates with Jetleaf's reflection system and naming strategy.
///
/// ### Core Features
/// - Reflective field population for any Dart object type.
/// - Supports `fromJson(Map<String, dynamic>)` and `@JsonCreator` constructors.
/// - Skips or defaults missing fields based on [JsonField] annotations.
/// - Applies custom converters declared via [JsonConverter].
/// - Honors naming strategy transformations between JSON and Dart fields.
/// - Optionally ignores unknown JSON properties.
///
/// ### Usage Example
/// ```dart
/// @JsonSerializable()
/// class Person {
///   final String name;
///   final int age;
///
///   const Person(this.name, this.age);
///
///   factory Person.fromJson(Map<String, dynamic> json) => Person(
///     json['name'] as String,
///     json['age'] as int,
///   );
/// }
///
/// final jsonParser = JsonParser.fromString('{"name":"Alice","age":30}');
/// final deserializer = DartDeserializer(Class<Person>(Person, "Person"));
/// final ctxt = DeserializationContext();
///
/// final person = deserializer.deserialize(jsonParser, ctxt) as Person;
/// print(person.name); // Alice
/// ```
///
/// ### Behavior Overview
/// | Behavior | Description |
/// |-----------|--------------|
/// | `@JsonCreator` | Invoked for object construction if present |
/// | `fromJson(Map)` | Fallback factory method |
/// | `@JsonIgnore` | Field skipped during mapping |
/// | `@JsonField(defaultValue)` | Default applied if field missing |
/// | `@JsonField(required: true)` | Throws on missing field |
/// | `@JsonConverter` | Applies field-level converter |
/// | Unknown keys | Ignored if `FAIL_ON_UNKNOWN_PROPERTIES` disabled |
///
/// ### Design Notes
/// - Complements [DartSerializer] for symmetrical reflection-based mapping.  
/// - Uses contextual [NamingStrategy] to align key formats.  
/// - Resilient against missing constructors or unknown types.  
/// - Prioritizes explicit annotations before fallback reflection.  
///
/// ### See Also
/// - [JsonDeserializer]
/// - [JsonConverter]
/// - [JsonField]
/// - [DeserializationFeature]
/// - [NamingStrategy]
/// {@endtemplate}
final class DartDeserializer implements JsonDeserializer<Object> {
  /// The reflected [Class] metadata representing the target Dart type.
  final Class _type;

  /// Creates a new [DartDeserializer] for the given type.
  ///
  /// {@macro jetleaf_dart_deserializer}
  DartDeserializer(this._type);

  @override
  bool canDeserialize(Class type) => type == _type;

  @override
  Object? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final token = parser.getCurrentToken();

    if (token == JsonToken.VALUE_NULL) {
      return null;
    }

    if (token != JsonToken.START_OBJECT) {
      throw InvalidFormatException('Expected START_OBJECT, got $token');
    }

    final naming = ctxt.getNamingStrategy();
    final allowUnknown = !ctxt.getObjectMapper().isFeatureEnabled(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES.name);
    final type = _type;
    final fieldValues = <String, Object>{};

    // Parse all JSON fields into Dart field map
    while (parser.nextToken()) {
      final currentToken = parser.getCurrentToken();

      if (currentToken == JsonToken.END_OBJECT) {
        break;
      }

      if (currentToken == JsonToken.FIELD_NAME) {
        final jsonKey = parser.getCurrentName()!;
        parser.nextToken();
        
        final jsonValue = parser.getCurrentValue();

        // Map JSON key → Dart field (do this before attempting nested delegation)
        final dartKey = naming.toDartName(jsonKey);
        final field = type.getField(dartKey);

        // Handle unknown properties
        if (field == null) {
          if (!allowUnknown) {
            throw JsonParsingException('Unknown property "$jsonKey" for type ${_type.getName()}');
          }

          continue;
        }

        final fieldClass = field.getReturnClass();

        // Skip ignored fields
        if (field.hasDirectAnnotation<JsonIgnore>()) continue;

        final jsonField = field.getDirectAnnotation<JsonField>();
        if (jsonField != null && jsonField.ignore) continue;

        // Handle @JsonField (default values / required)
        if (jsonValue == null) {
          final defaultValue = jsonField?.defaultValue;
          if (defaultValue != null) {
            fieldValues[dartKey] = defaultValue;
            continue;
          }
        }

        if (jsonValue == null && jsonField?.required == true) {
          throw JsonParsingException('Required field "$dartKey" missing for ${_type.getName()}');
        }

        // Apply @JsonConverter if present
        final jsonConverter = field.getDirectAnnotation<JsonConverter>();
        if (jsonConverter != null) {
          final converterInstance = jsonConverter.converter;
          final ct = jsonConverter.type;

          final adapter = ct != null ? ct.toClass().getNoArgConstructor()?.newInstance() : converterInstance;
          if (adapter != null && adapter is JsonDeserializer) {
            fieldValues[dartKey] = adapter.deserialize(parser, ctxt, fieldClass);
            continue;
          }
        }

        // Try type-based deserializer
        fieldValues[dartKey] = ctxt.deserialize(parser, fieldClass);
      }
    }

    // Construct the dart
    return _construct(fieldValues, type);
  }

  /// Constructs a Dart instance of [type] using the provided [fields].
  ///
  /// This method attempts resolution in the following order:
  /// 1. [FromJson] annotation creator, if present
  /// 2. Constructor annotated with [JsonCreator]
  /// 3. Static `fromJson(Map<String, dynamic>)` method
  /// 4. Other static factory methods accepting a single map argument
  /// 5. Default constructor with field assignments
  ///
  /// Returns `null` if instantiation fails.
  Object? _construct(Map<String, Object> fields, Class type) {
    final fromJson = type.getDirectAnnotation<FromJson>();
    if (fromJson != null) {
      return fromJson.creator(fields);
    }

    final constructor = type.getConstructors().find((c) => c.hasDirectAnnotation<JsonCreator>());
    if (constructor != null) {
      return constructor.newInstance(fields, [fields]);
    }

    final fromJsonMethodIfAvailable = type.getMethod("fromJson");
    if (fromJsonMethodIfAvailable != null && fromJsonMethodIfAvailable.getParameterCount() == 1 && fromJsonMethodIfAvailable.isStatic()) {
      return fromJsonMethodIfAvailable.invoke(null, null, [fields]);
    }

    final invokable = type.getMethods().find((m) => m.canAcceptPositionalArguments([fields]));
    if (invokable != null && invokable.isStatic()) {
      return invokable.invoke(null, null, [fields]);
    }

    try {
      return type.newInstance(fields);
    } catch (_) {
      return null;
    }
  }

  @override
  Class<Object> toClass() => Class.fromQualifiedName(_type.getQualifiedName());
}