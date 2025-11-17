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

import 'dart:convert';

import 'package:jetleaf_convert/convert.dart';
import 'package:jetleaf_core/context.dart';
import 'package:jetleaf_core/core.dart';
import 'package:jetleaf_env/env.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:jetleaf_utils/utils.dart' as utils;

import '../adapters/date_time_json_converter_adapter.dart';
import '../adapters/duration_json_converter_adapter.dart';
import '../adapters/local_date_json_converter_adapter.dart';
import '../adapters/local_date_time_json_converter_adapter.dart';
import '../adapters/uri_json_converter_adapter.dart';
import '../adapters/url_json_converter_adapter.dart';
import '../adapters/zoned_date_time_json_converter_adapter.dart';
import '../base.dart';
import '../context/default_deserialization_context.dart';
import '../context/default_serializer_provider.dart';
import '../exceptions.dart';
import '../json/json_node.dart';
import '../naming_strategies.dart';
import '../serializers/standard_deserializers.dart';
import '../serializers/standard_serializers.dart';
import '../json/string_json_generator.dart';
import '../json/string_json_parser.dart';
import '../yaml/abstract_yaml_object_mapper.dart';

/// A factory function type for creating [JsonParser] instances from a raw JSON string.
///
/// Users can provide a custom parser implementation by assigning a factory of this type.
/// This allows full control over parsing behavior, such as supporting non-standard JSON,
/// streaming, or integrating with external libraries.
///
/// ### Example
/// ```dart
/// JsonParser myParserFactory(String content) => MyCustomJsonParser(content);
/// objectMapper.setJsonParserFactory(myParserFactory);
/// ```
typedef JsonParserFactory = JsonParser Function(String content);

/// {@template jetleaf_jetson_object_mapper}
/// A comprehensive **JSON object mapper** for Dart, supporting serialization
/// and deserialization of Dart objects to/from JSON.
///
/// This class handles standard types, collections, date/time values, URIs, and
/// supports pluggable custom serializers, deserializers, and converters.
///
/// ### Features
/// - Registers standard serializers/deserializers for common Dart types:
///   - Primitives: `String`, `int`, `double`, `bool`, `num`
///   - Collections: `List`, `Map`, `Set`
///   - Date/Time: `DateTime`, `ZonedDateTime`, `LocalDateTime`, `LocalDate`, `Duration`
///   - URIs: `Uri`, `Url`
/// - Supports custom adapters via [registerAdapter].
/// - Maintains a configurable [NamingStrategy] for field name mapping.
/// - Integrates with an [ApplicationContext] for environment and conversion services.
/// - Converts Dart objects to JSON string or map, and parses JSON content to Dart objects or [JsonNode] trees.
///
/// ### Usage Example
/// ```dart
/// final mapper = JetsonObjectMapper();
///
/// final jsonMap = {
///   'name': 'Alice',
///   'age': 30,
/// };
///
/// // Serialize to JSON string
/// final jsonString = mapper.writeValueAsString(jsonMap);
/// print(jsonString); // {"name":"Alice","age":30}
///
/// // Deserialize from JSON string
/// final map = mapper.readValue<Map<String, dynamic>>(jsonString, Class<Map<String, dynamic>>());
/// print(map['name']); // Alice
/// ```
///
/// ### Design Notes
/// - Thread-safe serialization and deserialization using `synchronized`.
/// - Lazily initializes internal components like [JsonGenerator], [SerializerProvider], and [DeserializationContext].
/// - Delegates type-specific serialization/deserialization to registered serializers/deserializers.
/// - Supports feature flags via [enableFeature] and [disableFeature].
/// {@endtemplate}
final class JetsonObjectMapper extends AbstractYamlObjectMapper implements ApplicationContextAware {
  /// Tracks all currently **enabled features** for serialization and deserialization.
  ///
  /// Features control optional behaviors such as pretty printing, custom formatting,
  /// or other serialization flags. Use [enableFeature] and [disableFeature] to
  /// modify the set at runtime.
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.enableFeature(SerializationFeature.INDENT_OUTPUT.name);
  /// print(objectMapper.isFeatureEnabled(SerializationFeature.INDENT_OUTPUT.name)); // true
  /// ```
  final Set<String> _features = {};

  /// Stores **registered serializers** for specific Dart types.
  ///
  /// Each serializer converts a Dart object of a given type into a JSON representation.
  /// The map key is the [Class] of the type, and the value is the corresponding [JsonSerializer].
  ///
  /// ### Behavior Notes
  /// - Standard serializers (e.g., for `String`, `int`, `List`, `Map`, `Set`) are
  ///   registered automatically on construction.
  /// - Custom serializers can be added via [registerSerializer].
  /// - The map is used internally by the [SerializerProvider] to locate the correct
  ///   serializer at runtime.
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.registerSerializer(Class<MyCustomType>(), MyCustomSerializer());
  /// ```
  final Map<Class, JsonSerializer> _serializers = {};

  /// Stores **registered deserializers** for specific Dart types.
  ///
  /// Each deserializer converts a JSON value into a Dart object of a given type.
  /// The map key is the [Class] of the target type, and the value is the corresponding [JsonDeserializer].
  ///
  /// ### Behavior Notes
  /// - Standard deserializers (e.g., for `String`, `int`, `List`, `Map`, `Set`) are
  ///   registered automatically on construction.
  /// - Custom deserializers can be added via [registerDeserializer] or [registerAdapter].
  /// - The map is used internally by the [DeserializationContext] to locate the correct
  ///   deserializer at runtime.
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.registerDeserializer(Class<MyCustomType>(), MyCustomDeserializer());
  /// ```
  final Map<Class, JsonDeserializer> _deserializers = {};

  /// Optional [ConversionService] used for type conversions during
  /// serialization and deserialization.
  ///
  /// If not explicitly set, a default [SimpleConversionService] will be used.
  /// Typically injected from the [ApplicationContext] or set via
  /// [setConversionService].
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setConversionService(MyCustomConversionService());
  /// ```
  ConversionService? _conversionService;

  /// Optional [Environment] providing configuration properties and environment
  /// variables.
  ///
  /// If not explicitly set, a default [GlobalEnvironment] is used. Typically
  /// injected from the [ApplicationContext] or set via [setEnvironment].
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setEnvironment(myEnvironment);
  /// ```
  Environment? _environment;

  /// The [NamingStrategy] used to convert Dart field names to JSON property names.
  ///
  /// Defaults to [SnakeCaseNamingStrategy]. Can be customized using
  /// [setNamingStrategy].
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setNamingStrategy(CamelCaseNamingStrategy());
  /// ```
  NamingStrategy _namingStrategy = SnakeCaseNamingStrategy();

  /// Optional factory function to create a [JsonParser] from a string of JSON content.
  ///
  /// If not set, the mapper falls back to the default [StringJsonParser].
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setJsonParserFactory((content) => MyCustomJsonParser(content));
  /// ```
  JsonParserFactory? _jsonParserFactory;

  /// Lazily initialized [JsonGenerator] used for serializing Dart objects to JSON.
  ///
  /// Created on first access via [getJsonGenerator], with optional pretty-print
  /// settings based on enabled features.
  JsonGenerator? _jsonGenerator;

  /// Lazily initialized [SerializerProvider] responsible for locating and invoking
  /// the correct [JsonSerializer] for each object type.
  ///
  /// Created on first access via [getProvider].
  SerializerProvider? _serializerProvider;

  /// Lazily initialized [DeserializationContext] responsible for locating and invoking
  /// the correct [JsonDeserializer] for each object type.
  ///
  /// Created on first access via [getContext].
  DeserializationContext? _deserializationContext;

  /// {@macro jetleaf_jetson_object_mapper}
  ///
  /// Creates a new [JetsonObjectMapper] and registers all standard
  /// serializers and deserializers.
  JetsonObjectMapper([bool autoRegisterStandardAdapters = true]) {
    if (autoRegisterStandardAdapters) {
      _registerStandardDeserializers();
      _registerStandardSerializers();
    }
  }

  /// Registers all **standard serializers and adapters** for common Dart types.
  ///
  /// This method is called internally by the constructor to ensure that
  /// primitives, collections, date/time types, and URIs have default
  /// serialization behavior.
  ///
  /// ### Registered Types
  /// **Primitives**
  /// - `String` → [StringSerializer]
  /// - `int` → [IntSerializer]
  /// - `double` → [DoubleSerializer]
  /// - `bool` → [BoolSerializer]
  /// - `num` → [NumSerializer]
  ///
  /// **Collections**
  /// - `List` → [ListSerializer]
  /// - `Map` → [MapSerializer]
  /// - `Set` → [SetSerializer]
  ///
  /// **Date/Time (via converter adapters)**
  /// - `DateTime` → [DateTimeJsonConverterAdapter]
  /// - `ZonedDateTime` → [ZonedDateTimeJsonConverterAdapter]
  /// - `LocalDateTime` → [LocalDateTimeJsonConverterAdapter]
  /// - `LocalDate` → [LocalDateJsonConverterAdapter]
  /// - `Duration` → [DurationJsonConverterAdapter]
  ///
  /// **URIs**
  /// - `Uri` → [UriJsonConverterAdapter]
  /// - `Url` → [UrlJsonConverterAdapter]
  ///
  /// ### Design Notes
  /// - Uses [registerSerializer] for direct serializers and [registerAdapter]
  ///   for types that require conversion adapters.
  /// - Ensures that common types are always supported without additional configuration.
  ///
  /// ### Example
  /// ```dart
  /// final mapper = JetsonObjectMapper();
  /// // Standard serializers are already registered.
  /// final jsonString = mapper.writeValueAsString({'date': DateTime.now()});
  /// ```
  void _registerStandardSerializers() {
    // Primitives
    registerSerializer(Class<String>(), StringSerializer());
    registerSerializer(Class<int>(), IntSerializer());
    registerSerializer(Class<double>(), DoubleSerializer());
    registerSerializer(Class<bool>(), BoolSerializer());
    registerSerializer(Class<num>(), NumSerializer());

    // Collections
    registerSerializer(Class<List>(), ListSerializer());
    registerSerializer(Class<Map>(), MapSerializer());
    registerSerializer(Class<Set>(), SetSerializer());

    // Date/Time (from converter adapters)
    registerAdapter(Class<DateTime>(), const DateTimeJsonConverterAdapter());
    registerAdapter(Class<ZonedDateTime>(), const ZonedDateTimeJsonConverterAdapter());
    registerAdapter(Class<LocalDateTime>(), const LocalDateTimeJsonConverterAdapter());
    registerAdapter(Class<LocalDate>(), const LocalDateJsonConverterAdapter());
    registerAdapter(Class<Duration>(), const DurationJsonConverterAdapter());

    // URIs
    registerAdapter(Class<Uri>(), const UriJsonConverterAdapter());
    registerAdapter(Class<Url>(), const UrlJsonConverterAdapter());
  }

  /// Registers all **standard deserializers** for common Dart types.
  ///
  /// This method is called internally by the constructor to ensure that
  /// primitives and collections can be deserialized from JSON without
  /// additional configuration.
  ///
  /// ### Registered Types
  /// **Primitives**
  /// - `String` → [StringDeserializer]
  /// - `int` → [IntDeserializer]
  /// - `double` → [DoubleDeserializer]
  /// - `bool` → [BoolDeserializer]
  /// - `num` → [NumDeserializer]
  ///
  /// **Collections**
  /// - `List` → [ListDeserializer]
  /// - `Map` → [MapDeserializer]
  /// - `Set` → [SetDeserializer]
  ///
  /// ### Design Notes
  /// - Uses [registerDeserializer] to map JSON values to Dart types.
  /// - Ensures that common primitive and collection types are always supported.
  /// - Works in conjunction with [DeserializationContext] to locate the correct
  ///   deserializer at runtime.
  ///
  /// ### Example
  /// ```dart
  /// final mapper = JetsonObjectMapper();
  /// final json = '{"numbers":[1,2,3]}';
  /// final result = mapper.readValue<Map<String, dynamic>>(json, Class<Map<String, dynamic>>());
  /// print(result['numbers']); // [1, 2, 3]
  /// ```
  void _registerStandardDeserializers() {
    // Primitives
    registerDeserializer(Class<String>(), StringDeserializer());
    registerDeserializer(Class<int>(), IntDeserializer());
    registerDeserializer(Class<double>(), DoubleDeserializer());
    registerDeserializer(Class<bool>(), BoolDeserializer());
    registerDeserializer(Class<num>(), NumDeserializer());

    // Collections
    registerDeserializer(Class<List>(), ListDeserializer());
    registerDeserializer(Class<Map>(), MapDeserializer());
    registerDeserializer(Class<Set>(), SetDeserializer());
  }

  @override
  void disableFeature(String featureName) {
    _features.remove(featureName);
  }

  @override
  void enableFeature(String featureName) {
    _features.add(featureName);
  }

  /// Returns the active [DeserializationContext], initializing it if necessary.
  ///
  /// The [DeserializationContext] is responsible for locating and invoking the
  /// correct deserializer for each type at runtime. If it has not yet been created,
  /// a [DefaultDeserializationContext] is instantiated using the current
  /// object mapper and registered deserializers.
  ///
  /// ### Example
  /// ```dart
  /// final context = objectMapper.getContext();
  /// final result = context.deserialize(parser, Class<MyType>());
  /// ```
  DeserializationContext getContext() => _deserializationContext ??= DefaultDeserializationContext(this, _deserializers);

  @override
  ConversionService getConversionService() => _conversionService ?? SimpleConversionService();

  @override
  Environment getEnvironment() => _environment ?? GlobalEnvironment();

  /// Returns the active [JsonGenerator], initializing it lazily if necessary.
  ///
  /// The generator is used to serialize Dart objects into JSON strings. It
  /// respects the `SerializationFeature.INDENT_OUTPUT` feature for pretty-printing
  /// and uses an indent size from the environment, defaulting to 2.
  ///
  /// ### Example
  /// ```dart
  /// final generator = objectMapper.getJsonGenerator();
  /// generator.writeStartObject();
  /// generator.writeFieldName('name');
  /// generator.writeString('Alice');
  /// generator.writeEndObject();
  /// print(generator.toJsonString()); // {"name":"Alice"}
  /// ```
  JsonGenerator getJsonGenerator() => _jsonGenerator ??= StringJsonGenerator(
    pretty: isFeatureEnabled(SerializationFeature.INDENT_OUTPUT.name),
    indentSize: getEnvironment().getPropertyAs(ObjectMapper.INDENT_SIZE, Class<int>(), 2) ?? 2
  );

  /// Returns a [JsonParser] for the given JSON [content].
  ///
  /// If a custom parser factory has been provided via [setJsonParserFactory],
  /// it is used to create the parser. Otherwise, the default [StringJsonParser]
  /// is used as a fallback.
  ///
  /// ### Example
  /// ```dart
  /// final parser = objectMapper.getJsonParser('{"name":"Alice"}');
  /// parser.nextToken(); // advances to START_OBJECT
  /// ```
  JsonParser getJsonParser(String content) {
    if (_jsonParserFactory != null) {
      return _jsonParserFactory!(content);
    }

    // fallback to default parser if no factory provided
    return StringJsonParser(content);
  }

  /// Returns the active [SerializerProvider], initializing it lazily if necessary.
  ///
  /// The [SerializerProvider] is responsible for locating and invoking the
  /// correct serializer for each object type at runtime. It uses the
  /// [_serializers] map for type resolution.
  ///
  /// ### Example
  /// ```dart
  /// final provider = objectMapper.getProvider();
  /// provider.serialize({'name': 'Alice'}, objectMapper.getJsonGenerator());
  /// ```
  SerializerProvider getProvider() => _serializerProvider ??= DefaultSerializerProvider(this, _serializers);

  @override
  NamingStrategy getNamingStrategy() => _namingStrategy;

  @override
  ObjectMapper getObjectMapper() => this;

  @override
  bool isFeatureEnabled(String featureName) => _features.contains(featureName);

  @override
  JsonNode readContentTree(String content) {
    final parser = getJsonParser(content);
    final node = readTree(parser);

    parser.close();
    return node;
  }

  @override
  JsonNode readTree(JsonParser parser) {
    if (parser.getCurrentToken() == JsonToken.START_OBJECT) {
      final node = JsonObjectNode();
      parser.nextToken();
      while (parser.getCurrentToken() != JsonToken.END_OBJECT) {
        final key = parser.getCurrentName()!;
        parser.nextToken();
        node.set(key, readTree(parser));
        parser.nextToken();
      }

      return node;
    } else if (parser.getCurrentToken() == JsonToken.START_ARRAY) {
      final node = JsonArrayNode();
      parser.nextToken();
      while (parser.getCurrentToken() != JsonToken.END_ARRAY) {
        node.add(readTree(parser));
        parser.nextToken();
      }

      return node;
    } else if (parser.getCurrentToken() == JsonToken.VALUE_STRING) {
      return JsonTextNode(parser.getCurrentValue().toString());
    } else if (parser.getCurrentToken() == JsonToken.VALUE_NUMBER) {
      return JsonNumberNode(parser.getCurrentValue() as num);
    } else if (parser.getCurrentToken() == JsonToken.VALUE_BOOLEAN) {
      return JsonBooleanNode(parser.getCurrentValue() as bool);
    } else if (parser.getCurrentToken() == JsonToken.VALUE_NULL) {
      return JsonNullNode();
    }

    throw JsonParsingException('Unknown JSON token: ${parser.getCurrentToken()}');
  }

  @override
  T readValue<T>(String json, Class<T> type) {
    final parser = getJsonParser(json);
    final result = getContext().deserialize(parser, type);

    parser.close();
    return result;
  }

  @override
  T readValueFromMap<T>(Map<String, dynamic> map, Class<T> type) {
    final content = jsonEncode(map);
    return readValue(content, type);
  }

  @override
  void registerAdapter(Class type, JsonConverterAdapter adapter) {
    return synchronized(this, () {
      _deserializers.put(type, adapter);
      _serializers.put(type, adapter);
    });
  }

  @override
  void registerDeserializer(Class type, JsonDeserializer deserializer) {
    _deserializers.put(type, deserializer);
  }

  @override
  void registerSerializer(Class type, JsonSerializer serializer) {
    _serializers.put(type, serializer);
  }

  @override
  void setApplicationContext(ApplicationContext applicationContext) {
    if (_conversionService == null) {
      _conversionService = applicationContext.getConversionService();
    }

    if (_environment == null) {
      _environment = applicationContext.getEnvironment();
    }
  }

  /// Sets the [ConversionService] to be used by this mapper for type conversions.
  ///
  /// If not explicitly set, a default [SimpleConversionService] is used.
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setConversionService(MyCustomConversionService());
  /// ```
  void setConversionService(ConversionService conversionService) {
    _conversionService = conversionService;
  }

  /// Sets the [Environment] used by this mapper to look up configuration properties
  /// and environment variables.
  ///
  /// If not explicitly set, a default [GlobalEnvironment] is used.
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setEnvironment(myEnvironment);
  /// ```
  void setEnvironment(Environment environment) {
    _environment = environment;
  }

  /// Sets a custom JSON parser factory to create [JsonParser] instances from
  /// raw JSON strings.
  ///
  /// If not set, the mapper falls back to the default [StringJsonParser].
  ///
  /// ### Example
  /// ```dart
  /// objectMapper.setJsonParserFactory((content) => MyCustomJsonParser(content));
  /// ```
  void setJsonParserFactory(JsonParserFactory factory) {
    _jsonParserFactory = factory;
  }

  @override
  void setJsonGenerator(JsonGenerator jsonGenerator) {
    _jsonGenerator = jsonGenerator;
  }

  @override
  void setNamingStrategy(NamingStrategy strategy) {
    _namingStrategy = strategy;
  }

  @override
  void setSerializerProvider(SerializerProvider provider) {
    _serializerProvider = provider;
  }

  @override
  void setDeserializationContext(DeserializationContext context) {
    _deserializationContext = context;
  }

  @override
  Map<String, dynamic> writeValueAsMap(Object? value) {
    if (value == null) return {};
    
    final generator = getJsonGenerator();
    
    return synchronized(generator, () {
      getProvider().serialize(value, generator);
      final json = generator.toJsonString();

      return utils.JsonParser().parse(json);
    });
  }

  @override
  String writeValueAsString(Object? value) {
    final generator = getJsonGenerator();

    return synchronized(generator, () {
      getProvider().serialize(value, generator);
      return generator.toJsonString();
    });
  }
}