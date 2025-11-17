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
import 'jetson_object_mapper.dart';

/// {@template jetleaf_jetson2_object_mapper_builder}
/// A **fluent builder** for constructing fully-configured [JetsonObjectMapper] instances.
///
/// This builder enables step-by-step configuration of the mapper, allowing
/// users to set naming strategies, conversion services, environment variables,
/// parser factories, feature flags, and custom serializers/deserializers. It
/// supports auto-registration of standard adapters for primitives, collections,
/// date/time types, and URIs.
///
/// ### Features
/// - Fluent API for configuring mapper components.
/// - Full control over naming strategies via [NamingStrategy].
/// - Custom type conversions using [ConversionService].
/// - Environment integration for configuration values through [Environment].
/// - Support for custom [JsonParser] factories for parsing JSON content.
/// - Fine-grained control over feature flags:
///   - Mapper-level features
///   - Serialization features
///   - Deserialization features
/// - Registration of custom serializers and deserializers for user-defined types.
/// - Optional automatic registration of standard adapters for common types.
///
/// ### Usage Example
/// ```dart
/// final mapper = JetsonObjectMapperBuilder()
///     .namingStrategy(CamelCaseNamingStrategy())
///     .conversionService(MyConversionService())
///     .environment(myEnvironment)
///     .enableSerializationFeature(SerializationFeature.INDENT_OUTPUT.name)
///     .serializers({Class<MyType>(): MyTypeSerializer()})
///     .deserializers({Class<MyType>(): MyTypeDeserializer()})
///     .build();
///
/// final json = mapper.writeValueAsString({'name': 'Alice'});
/// print(json);
/// ```
/// {@endtemplate}
final class JetsonObjectMapperBuilder {
  // ─────────────────────────────────────────────────────────────
  // Configuration fields
  // ─────────────────────────────────────────────────────────────

  /// Optional [NamingStrategy] for controlling the conversion of Dart field names
  /// to JSON property names during serialization and deserialization.
  ///
  /// If not set, the default naming strategy of the [JetsonObjectMapper] will
  /// be used. Common strategies include [SnakeCaseNamingStrategy] and
  /// [CamelCaseNamingStrategy].
  ///
  /// ### Example
  /// ```dart
  /// builder.namingStrategy(CamelCaseNamingStrategy());
  /// ```
  NamingStrategy? _namingStrategy;

  /// Optional [ConversionService] used for automatic type conversions
  /// during serialization and deserialization.
  ///
  /// If not explicitly provided, a default [SimpleConversionService] will be
  /// used by the resulting mapper. Custom conversion services can handle
  /// advanced scenarios like converting between custom date/time types or
  /// domain-specific objects.
  ///
  /// ### Example
  /// ```dart
  /// builder.conversionService(MyCustomConversionService());
  /// ```
  ConversionService? _conversionService;

  /// Optional [Environment] used to retrieve configuration properties
  /// and environment variables.
  ///
  /// The environment can provide runtime settings, such as default indentation
  /// size or feature flags. If not set, [GlobalEnvironment] will be used
  /// as a fallback.
  ///
  /// ### Example
  /// ```dart
  /// builder.environment(myEnvironment);
  /// ```
  Environment? _environment;

  /// Optional factory function for creating [JsonParser] instances from raw
  /// JSON strings.
  ///
  /// This allows using custom parser implementations instead of the default
  /// [StringJsonParser]. Useful for optimized parsing, streaming scenarios,
  /// or supporting custom JSON dialects.
  ///
  /// ### Example
  /// ```dart
  /// builder.jsonParserFactory((content) => MyCustomJsonParser(content));
  /// ```
  JsonParserFactory? _jsonParserFactory;

  /// The currently active [JsonGenerator] used for serializing Dart objects to JSON.
  ///
  /// This generator is lazily initialized when first accessed via [getJsonGenerator].
  /// Users can override it by calling [setJsonGenerator] to inject a custom implementation,
  /// for example to write JSON to a specific buffer, file, or network stream.
  ///
  /// It respects feature flags such as [SerializationFeature.INDENT_OUTPUT] for pretty-printing
  /// and uses the configured [INDENT_SIZE] from the environment.
  JsonGenerator? _jsonGenerator;

  /// Feature flags controlling general mapper behavior.
  ///
  /// These flags are applied during the build process. Examples include enabling
  /// pretty printing, validation, or custom logging behavior.
  final Map<String, bool> _mapperFeatures = {};

  /// Feature flags controlling serialization behavior.
  ///
  /// These flags affect how the mapper writes objects to JSON, such as enabling
  /// indentation or applying custom formatting rules.
  final Map<String, bool> _serializationFeatures = {};

  /// Feature flags controlling deserialization behavior.
  ///
  /// These flags affect how the mapper reads JSON into Dart objects, such as
  /// ignoring unknown fields, strict type enforcement, or null handling.
  final Map<String, bool> _deserializationFeatures = {};

  /// Custom [JsonSerializer] instances registered for specific Dart types.
  ///
  /// Each serializer defines how a Dart object is converted to JSON.
  /// Standard serializers are automatically registered if [_autoRegisterStandardAdapters] is `true`.
  ///
  /// ### Example
  /// ```dart
  /// builder.serializers({Class<MyType>(): MyTypeSerializer()});
  /// ```
  final Map<Class, JsonSerializer<Object>> _serializers = {};

  /// Custom [JsonDeserializer] instances registered for specific Dart types.
  ///
  /// Each deserializer defines how JSON values are converted back to Dart objects.
  /// Standard deserializers are automatically registered if [_autoRegisterStandardAdapters] is `true`.
  ///
  /// ### Example
  /// ```dart
  /// builder.deserializers({Class<MyType>(): MyTypeDeserializer()});
  /// ```
  final Map<Class, JsonDeserializer<Object>> _deserializers = {};

  /// Whether standard adapters for common Dart types (primitives, collections,
  /// date/time types, and URIs) should be automatically registered.
  ///
  /// Defaults to `true`. Disabling this allows full control over the adapters,
  /// but requires manual registration for all types used.
  ///
  /// ### Example
  /// ```dart
  /// builder.autoRegisterStandardAdapters(false);
  /// ```
  bool _autoRegisterStandardAdapters = true;

  // ─────────────────────────────────────────────────────────────
  // Builder methods
  // ─────────────────────────────────────────────────────────────

  /// Sets the [NamingStrategy] for the resulting mapper.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder namingStrategy(NamingStrategy strategy) {
    _namingStrategy = strategy;
    return this;
  }

  /// Sets the [ConversionService] for type conversions.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder conversionService(ConversionService service) {
    _conversionService = service;
    return this;
  }

  /// Sets the [Environment] for configuration property resolution.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder environment(Environment env) {
    _environment = env;
    return this;
  }

  /// Sets a custom JSON parser factory.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder jsonParserFactory(JsonParserFactory factory) {
    _jsonParserFactory = factory;
    return this;
  }

  /// Sets a custom [JsonGenerator] for the object mapper being built.
  ///
  /// This allows users to override the default JSON generator used for serialization.
  /// Once set, the provided generator will be used whenever the object mapper
  /// serializes Dart objects to JSON strings or maps.
  ///
  /// This is part of the builder pattern, so the method returns the builder itself
  /// to allow fluent chaining of configuration calls.
  ///
  /// ### Example
  /// ```dart
  /// final mapper = JetsonObjectMapperBuilder()
  ///     .jsonGenerator(MyCustomJsonGenerator())
  ///     .build();
  /// ```
  JetsonObjectMapperBuilder jsonGenerator(JsonGenerator jsonGenerator) {
      _jsonGenerator = jsonGenerator;
      return this;
  }

  /// Enables or disables automatic registration of standard adapters.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder autoRegisterStandardAdapters(bool enabled) {
    _autoRegisterStandardAdapters = enabled;
    return this;
  }

  /// Enables a mapper-level feature.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder enableMapperFeature(String featureName) {
    _mapperFeatures[featureName] = true;
    return this;
  }

  /// Disables a mapper-level feature.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder disableMapperFeature(String featureName) {
    _mapperFeatures[featureName] = false;
    return this;
  }

  /// Enables a serialization feature.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder enableSerializationFeature(String featureName) {
    _serializationFeatures[featureName] = true;
    return this;
  }

  /// Disables a serialization feature.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder disableSerializationFeature(String featureName) {
    _serializationFeatures[featureName] = false;
    return this;
  }

  /// Enables a deserialization feature.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder enableDeserializationFeature(String featureName) {
    _deserializationFeatures[featureName] = true;
    return this;
  }

  /// Disables a deserialization feature.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder disableDeserializationFeature(String featureName) {
    _deserializationFeatures[featureName] = false;
    return this;
  }

  /// Registers custom [JsonSerializer] instances.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder serializers(Map<Class, JsonSerializer<Object>> serializers) {
    _serializers.addAll(serializers);
    return this;
  }

  /// Registers custom [JsonDeserializer] instances.
  ///
  /// Returns the builder instance for method chaining.
  JetsonObjectMapperBuilder deserializers(Map<Class, JsonDeserializer<Object>> deserializers) {
    _deserializers.addAll(deserializers);
    return this;
  }

  // ─────────────────────────────────────────────────────────────
  // Build method
  // ─────────────────────────────────────────────────────────────

  /// Constructs a fully-configured [JetsonObjectMapper] based on the builder settings.
  ///
  /// Applies all configured naming strategies, conversion services, environment,
  /// parser factories, feature flags, and custom serializers/deserializers.
  ///
  /// If [_autoRegisterStandardAdapters] is `true`, standard adapters for
  /// primitives, collections, date/time types, and URIs are registered automatically.
  ///
  /// ### Example
  /// ```dart
  /// final mapper = JetsonObjectMapperBuilder()
  ///     .namingStrategy(CamelCaseNamingStrategy())
  ///     .enableSerializationFeature(SerializationFeature.INDENT_OUTPUT.name)
  ///     .build();
  /// ```
  ObjectMapper build() {
    final mapper = JetsonObjectMapper(_autoRegisterStandardAdapters);

    if (_namingStrategy != null) mapper.setNamingStrategy(_namingStrategy!);
    if (_conversionService != null) mapper.setConversionService(_conversionService!);
    if (_environment != null) mapper.setEnvironment(_environment!);
    if (_jsonParserFactory != null) mapper.setJsonParserFactory(_jsonParserFactory!);
    if (_jsonGenerator != null) mapper.setJsonGenerator(_jsonGenerator!);

    _mapperFeatures.forEach((name, enabled) {
      if (enabled) mapper.enableFeature(name);
      else mapper.disableFeature(name);
    });

    _serializationFeatures.forEach((name, enabled) {
      if (enabled) mapper.enableFeature(name);
      else mapper.disableFeature(name);
    });

    _deserializationFeatures.forEach((name, enabled) {
      if (enabled) mapper.enableFeature(name);
      else mapper.disableFeature(name);
    });

    _serializers.forEach((type, serializer) => mapper.registerSerializer(type, serializer));
    _deserializers.forEach((type, deserializer) => mapper.registerDeserializer(type, deserializer));

    return mapper;
  }
}