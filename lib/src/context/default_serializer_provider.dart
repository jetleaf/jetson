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

import 'package:jetleaf_convert/convert.dart';
import 'package:jetleaf_env/env.dart';
import 'package:jetleaf_lang/lang.dart';

import '../base.dart';
import '../serializers/dart_serializer.dart';

/// {@template default_serializer_provider}
/// Default implementation of [SerializerProvider] for JetLeaf’s JSON subsystem.
///
/// The [DefaultSerializerProvider] is responsible for locating, caching,
/// and managing [JsonSerializer] instances used during object serialization.
/// It serves as the **central serialization registry**, queried by the
/// [ObjectMapper] whenever an object needs to be converted to JSON.
///
/// ### Responsibilities
/// - Maintain lookup caches for configured and framework-level serializers.
/// - Dynamically resolve serializers for user-defined or system types.
/// - Provide fallback to generic [DartSerializer] for unregistered classes.
/// - Integrate tightly with the [ObjectMapper] for consistent
///   configuration, naming, and conversion behavior.
///
/// ### Serializer Resolution Flow
/// 1. Attempt lookup in configured (user-provided) serializers.
/// 2. Fall back to framework-provided serializers.
/// 3. Check internal cache for a pre-resolved serializer.
/// 4. Match serializer by capability (`canSerialize`) or exact type match.
/// 5. If none is found, register and return a [DartSerializer] for the type.
///
/// ### Example
/// ```dart
/// final provider = DefaultSerializerProvider(objectMapper, {});
/// final serializer = provider.findSerializerForType(Class.of(MyModel));
/// serializer?.serialize(myModel, generator, provider);
/// ```
///
/// ### See also
/// - [JsonSerializer]
/// - [ObjectMapper]
/// - [SerializerProvider]
/// - [DartSerializer]
/// {@endtemplate}
@Author("Evaristus Adimonyemma")
final class DefaultSerializerProvider implements SerializerProvider {
  /// Internal cache mapping [Class] types to their resolved [JsonSerializer] instances.
  ///
  /// This cache is lazily populated as serializers are discovered or created.
  /// It includes both user-registered and framework-level serializers,
  /// enabling quick lookup without recomputation.
  final Map<Class, JsonSerializer> _serializers;

  /// The [ObjectMapper] associated with this provider.
  ///
  /// Provides global serialization configuration, including:
  /// - Naming strategy (e.g., snake_case, camelCase)
  /// - Conversion service for type coercion
  /// - Environmental context for feature flags or profiles
  final ObjectMapper _objectMapper;

  /// Cache of **user-configured** serializers explicitly registered
  /// by developers through the [ObjectMapper].
  ///
  /// These serializers take precedence over framework serializers,
  /// allowing user customization for domain-specific classes.
  Map<Class, JsonSerializer> _configuredSerializers = {};

  /// Cache of **framework-provided** serializers automatically discovered
  /// from the JetLeaf core packages (e.g., those under `PackageNames.JETSON`).
  ///
  /// These handle built-in types such as `String`, `int`, and JetLeaf entities.
  Map<Class, JsonSerializer> _frameworkSerializers = {};

  /// Creates a new [DefaultSerializerProvider] bound to the given [ObjectMapper].
  ///
  /// The [_serializers] map may optionally include pre-populated serializers.
  /// On initialization, the constructor automatically categorizes
  /// serializers into framework and configured caches based on package origin.
  ///
  /// {@macro default_serializer_provider}
  DefaultSerializerProvider(this._objectMapper, this._serializers) {
    for (final entry in _serializers.entries) {
      final key = entry.key;
      final s = entry.value;

      if (s.getClass().getPackage()?.getName() == PackageNames.JETSON) {
        _frameworkSerializers.add(key, s);
      } else {
        _configuredSerializers.add(key, s);
      }
    }
  }

  @override
  JsonSerializer? findSerializerForType(Class type) {
    final deserializer = find(type, _configuredSerializers) ?? find(type, _frameworkSerializers);

    if (deserializer != null) {
      return deserializer;
    }

    // Fall back to dart serializer for complex objects
    final dartSerializer = DartSerializer(type);
    _frameworkSerializers[type] = dartSerializer;

    return dartSerializer;
  }

  /// Attempts to locate a [JsonSerializer] for the specified [type]
  /// within the provided [serializers] map.
  ///
  /// The search follows a hierarchical matching strategy:
  /// 1. **Direct lookup:** Returns immediately if the type exists as a key.
  /// 2. **Capability match:** Checks each serializer’s `canSerialize` predicate.
  /// 3. **Type equivalence:** Matches serializers whose declared type or
  ///    underlying Dart type equals the requested [type].
  ///
  /// Returns the best-matching [JsonSerializer] or `null` if none found.
  ///
  /// ### Example
  /// ```dart
  /// final serializer = provider.find(Class.of(MyModel), configuredSerializers);
  /// if (serializer != null) {
  ///   print("Found serializer for ${serializer.toClass().getName()}");
  /// }
  /// ```
  JsonSerializer? find(Class type, Map<Class, JsonSerializer> serializers) {
    if (serializers.containsKey(type)) {
      return serializers[type];
    }

    JsonSerializer? serializer = serializers.values.find((serializer) => serializer.canSerialize(type));
    if (serializer != null) {
      return serializer;
    }

    serializer = serializers.values.find((ss) => ss.toClass() == type || ss.toClass().getType() == type.getType());
    if (serializer != null) {
      return serializer;
    }

    return null;
  }

  @override
  ObjectMapper getObjectMapper() => _objectMapper;

  @override
  NamingStrategy getNamingStrategy() => _objectMapper.getNamingStrategy();

  @override
  ConversionService getConversionService() => _objectMapper.getConversionService();

  @override
  Environment getEnvironment() => _objectMapper.getEnvironment();

  @override
  void serialize(Object? object, JsonGenerator generator) {
    if (object == null) {
      generator.writeNull();
      return null;
    }

    // Find appropriate serializer
    final type = object.getClass();
    final serializer = findSerializerForType(type);

    if (serializer != null) {
      serializer.serialize(object, generator, this);
    } else {
      // Fallback: write as string
      generator.writeString(object.toString());
    }
  }
}