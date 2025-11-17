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

import 'object_mapper/jetson_object_mapper.dart';
import 'json/json_node.dart';

/// {@template serializer}
/// Base interface for all serializers within the JetLeaf mapping framework.
///
/// A [BaseSerializer] provides access to shared components that drive JSON
/// serialization — including the active [ObjectMapper], [NamingStrategy],
/// and [ConversionService].  
///
/// This interface defines the contextual backbone used by higher-level
/// abstractions like [SerializerProvider] and concrete serializers
/// (e.g., [JsonSerializer]).
///
/// ### Overview
/// - Exposes serialization configuration and environment context  
/// - Provides consistent naming and conversion behavior  
/// - Used internally by [ObjectMapper] and serializer adapters
///
/// ### Example
/// ```dart
/// final naming = serializer.getNamingStrategy();
/// final jsonKey = naming.toJsonName('userName'); // user_name
/// ```
///
/// ### See also
/// - [ObjectMapper]
/// - [NamingStrategy]
/// - [ConversionService]
/// - [SerializerProvider]
/// {@endtemplate}
abstract interface class BaseSerializer {
  /// Returns the **active [ObjectMapper]** performing serialization.
  ///
  /// The [ObjectMapper] provides access to JetLeaf’s configuration,
  /// registered modules, serializer registry, and naming conventions.
  ///
  /// ### Example
  /// ```dart
  /// final mapper = serializer.getObjectMapper();
  /// final json = mapper.writeValueAsString(user);
  /// ```
  ///
  /// ### Notes
  /// - Enables recursive serialization for nested objects  
  /// - May expose internal feature flags and serializer adapters  
  /// - Should not be `null` during active serialization
  ObjectMapper getObjectMapper();

  /// Returns the **naming strategy** used for field name conversion.
  ///
  /// The [NamingStrategy] controls how Dart property names are transformed
  /// into JSON-compatible keys, enabling conventions such as
  /// `camelCase`, `snake_case`, or `kebab-case`.
  ///
  /// ### Example
  /// ```dart
  /// final strategy = serializer.getNamingStrategy();
  /// final jsonKey = strategy.toJsonName('createdAt');
  /// print(jsonKey); // created_at
  /// ```
  ///
  /// ### Notes
  /// - Ensures consistent key naming across serializers  
  /// - Used by property-level serializers during object traversal  
  /// - Should be reversible via [NamingStrategy.toDartName]
  NamingStrategy getNamingStrategy();

  /// Returns the **global [ConversionService]** responsible for
  /// type coercions and primitive value conversions.
  ///
  /// The [ConversionService] provides a unified interface for adapting
  /// types between Dart primitives, enums, and other supported conversions.
  ///
  /// ### Example
  /// ```dart
  /// final service = serializer.getConversionService();
  /// final value = service.convert<int>('42');
  /// print(value); // 42
  /// ```
  ///
  /// ### Notes
  /// - Enables consistent numeric, string, and enum conversions  
  /// - Accessible to custom serializers and adapters  
  /// - Should be thread-safe and stateless where possible
  ConversionService getConversionService();

  /// Returns the active [Environment] configuration associated with this mapper.
  ///
  /// The [Environment] defines runtime configuration and context for the
  /// serialization/deserialization.
  ///
  /// ### Responsibilities
  /// - Exposes active profiles and property values  
  /// - Provides configuration lookup for converters and modules  
  /// - Influences conditional serialization rules or module registration  
  ///
  /// ### Example
  /// ```dart
  /// final env = objectMapper.getEnvironment();
  /// if (env.activeProfiles.contains('production')) {
  ///   // Customize behavior for production mode
  /// }
  /// ```
  ///
  /// ### See also
  /// - [ObjectMapper]
  /// - [JsonSerializer]
  /// - [JsonDeserializer]
  Environment getEnvironment();
}

/// {@template object_mapper}
/// Provides a unified abstraction for **object serialization and deserialization**
/// within the JetLeaf framework.
///
/// The [ObjectMapper] serves as the central entry point for converting between
/// Dart objects and their JSON (or `Map<String, dynamic>`) representations.
/// It respects naming strategies, annotations, and registered converters,
/// enabling consistent and extensible data mapping.
///
/// ### Core Responsibilities
/// - Serialize objects to JSON strings or maps
/// - Deserialize JSON data into strongly typed Dart objects
/// - Manage custom serializers, deserializers, and adapters
/// - Apply naming strategies and type coercion via [ConversionService]
///
/// ### Example
/// ```dart
/// final mapper = DefaultObjectMapper();
/// mapper.setNamingStrategy(SnakeCaseNamingStrategy());
///
/// final user = User(name: 'Alice', age: 30);
/// final json = mapper.writeValueAsString(user);
///
/// final restored = mapper.readValue<User>(json, Class<User>());
/// ```
///
/// ### Extensibility
/// - Register new [JsonSerializer] or [JsonDeserializer] implementations
/// - Customize field name mapping via [NamingStrategy]
/// - Integrate type converters through [ConversionService]
///
/// ### See also
/// - [NamingStrategy]
/// - [JsonSerializer]
/// - [JsonDeserializer]
/// - [ConversionService]
/// - [JsonConverterAdapter]
/// {@endtemplate}
abstract interface class ObjectMapper implements BaseSerializer {
  /// The configuration key for specifying the default timezone used by Jetson.
  ///
  /// When set, this property controls how date and time values are serialized
  /// and deserialized across all mappers and converters.
  ///
  /// ### Default
  /// If not explicitly set, Jetson uses the system’s local timezone.
  ///
  /// ### Example
  /// ```dart
  /// environment.setProperty(ObjectMapper.TIMEZONE_PROPERTY, "UTC");
  /// ```
  ///
  /// This ensures that all `DateTime` values are serialized and parsed in UTC.
  ///
  /// ### See also
  /// - [Environment]
  /// - [getEnvironment]
  static const String TIMEZONE_PROPERTY = "jetson.timezone";

  /// Configuration property key for controlling the number of spaces used
  /// when pretty-printing JSON output.
  ///
  /// Example usage:
  /// ```dart
  /// environment.setProperty(JetsonObjectMapper.INDENT_SIZE, 4);
  /// ```
  /// This would indent JSON output with 4 spaces per level.
  static const String INDENT_SIZE = "jetson.pretty-print.indent-size";

  /// {@template object_mapper_factory}
  /// Creates a new instance of the default Jetson [ObjectMapper] implementation.
  ///
  /// This factory constructor instantiates and returns a fully configured
  /// [JetsonObjectMapper], the standard implementation of [ObjectMapper]
  /// within the Jetson framework.
  ///
  /// Use this factory when you want to obtain a ready-to-use, reflection-driven
  /// JSON (de)serialization engine.
  ///
  /// The returned [JetsonObjectMapper] includes:
  /// - Built-in support for Jetson annotations such as `@JsonField`, `@JsonIgnore`, and `@JsonCreator`.
  /// - Integration with Jetleaf’s `Class` reflection system.
  /// - Configurable naming strategies (e.g., `SnakeCaseNamingStrategy`).
  /// - Automatic discovery of registered `JsonConverterAdapter` implementations.
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// final mapper = ObjectMapper();
  ///
  /// final json = mapper.writeValueAsString(user);
  /// final user = mapper.readValue<User>(json);
  /// ```
  ///
  /// ---
  ///
  /// Returns a new [JetsonObjectMapper] each time it is invoked.
  /// To share configuration globally, you can use dependency injection
  /// or a singleton pattern.
  ///
  /// {@endtemplate}
  factory ObjectMapper() => JetsonObjectMapper();

  // ─────────────────────────────────────────────────────────────
  // Serialization
  // ─────────────────────────────────────────────────────────────

  /// Serializes a Dart object into a JSON string.
  ///
  /// Converts the given [value] into a JSON-encoded string using the current
  /// [NamingStrategy], annotations, and registered serializers.
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// final json = mapper.writeValueAsString(user);
  /// print(json);
  /// ```
  /// ---
  String writeValueAsString(Object? value);

  /// Parses the given JSON [content] string into a [JsonNode] tree.
  ///
  /// This allows you to traverse or inspect JSON data without binding it
  /// to a specific object type.
  ///
  /// Throws a parsing exception if the content is invalid JSON.
  ///
  /// ### Example
  /// ```dart
  /// final tree = objectMapper.readContentTree('{"name":"Alice"}');
  /// print(tree.get("name").toObject()); // "Alice"
  /// ```
  JsonNode readContentTree(String content);

  /// Reads and parses JSON content from the given [JsonParser] into a [JsonNode] tree.
  ///
  /// Useful when working with streaming or preconfigured parsers.
  /// The returned tree can be navigated like a DOM or queried dynamically.
  ///
  /// ### Example
  /// ```dart
  /// final parser = objectMapper.createParser('{"age":30}');
  /// final tree = objectMapper.readTree(parser);
  /// print(tree.get("age").toObject()); // 30
  /// ```
  JsonNode readTree(JsonParser parser);

  /// Serializes a Dart object into a `Map<String, dynamic>` representation.
  ///
  /// This method traverses all serializable fields of [value] and produces
  /// a map that can be safely passed to `jsonEncode`.
  ///
  /// It respects:
  /// - Field-level annotations like [`@JsonField`], [`@JsonIgnore`].
  /// - The configured [NamingStrategy].
  /// - Any registered [`JsonConverterAdapter`] or [`JsonConverter`].
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// final map = mapper.writeValueAsMap(user);
  /// print(map['name']); // Access individual fields
  /// ```
  ///
  /// ---
  Map<String, dynamic> writeValueAsMap(Object? value);

  // ─────────────────────────────────────────────────────────────
  // Deserialization
  // ─────────────────────────────────────────────────────────────

  /// Deserializes a JSON string into an object of type [T].
  ///
  /// The JSON is parsed into an intermediate map, which is then mapped
  /// to a Dart object using reflection and configured converters.
  ///
  /// The [type] parameter represents the target type metadata, allowing
  /// accurate handling of generics and nested structures.
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// final user = mapper.readValue<User>('{"name": "Alice"}', Class<User>());
  /// ```
  /// ---
  T readValue<T>(String json, Class<T> type);

  /// Deserializes a JSON-compatible map into an instance of type [T].
  ///
  /// This bypasses JSON parsing and directly performs field mapping from
  /// a [Map<String, dynamic>] to a Dart object.
  ///
  /// Useful when JSON data is already parsed (e.g., from a REST response).
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// final user = mapper.readValueFromMap<User>({
  ///   'name': 'Bob',
  ///   'age': 28,
  /// }, Class<User>());
  /// ```
  ///
  /// ---
  T readValueFromMap<T>(Map<String, dynamic> map, Class<T> type);

  // ─────────────────────────────────────────────────────────────
  // Registration
  // ─────────────────────────────────────────────────────────────

  /// Registers a custom serializer for type [T].
  ///
  /// This serializer will be used whenever an instance of [T] (or a subclass)
  /// is encountered during serialization.
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// mapper.registerSerializer(Class<DateTime>(), DateTimeSerializer());
  /// ```
  ///
  /// ---
  void registerSerializer(Class type, JsonSerializer serializer);

  /// Registers a custom deserializer for type [T].
  ///
  /// Used to control how JSON values are converted into Dart objects of type [T].
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// mapper.registerDeserializer(Class<DateTime>(), DateTimeDeserializer());
  /// ```
  ///
  /// ---
  void registerDeserializer(Class type, JsonDeserializer deserializer);

  /// Registers a bidirectional adapter ([JsonConverterAdapter]) for type [T].
  ///
  /// Equivalent to registering both a serializer and a deserializer.
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// mapper.registerAdapter<DateTime>(DateTimeAdapter());
  /// ```
  ///
  /// ---
  void registerAdapter(Class type, JsonConverterAdapter adapter);

  // ─────────────────────────────────────────────────────────────
  // Configuration
  // ─────────────────────────────────────────────────────────────

  /// Sets the active [NamingStrategy] used during (de)serialization.
  ///
  /// Determines how Dart field names are mapped to JSON keys.
  ///
  /// Built-in strategies include:
  /// - [CamelCaseNamingStrategy] (default)
  /// - [SnakeCaseNamingStrategy]
  /// - [KebabCaseNamingStrategy]
  ///
  /// ---
  ///
  /// ### Example:
  /// ```dart
  /// mapper.setNamingStrategy(SnakeCaseNamingStrategy());
  /// ```
  ///
  /// ---
  void setNamingStrategy(NamingStrategy strategy);

  /// Sets the active [JsonGenerator] used for serializing Dart objects to JSON.
  ///
  /// The provided [jsonGenerator] will be used by the mapper for all subsequent
  /// serialization operations. This allows users to inject a custom generator
  /// implementation, e.g., one that writes to a `StringBuffer`, a file, or
  /// a network stream.
  ///
  /// If not explicitly set, the mapper lazily creates a default [StringJsonGenerator]
  /// via [getJsonGenerator].
  ///
  /// ### Example
  /// ```dart
  /// final customGenerator = MyCustomJsonGenerator();
  /// objectMapper.setJsonGenerator(customGenerator);
  /// final json = objectMapper.writeValueAsString(myObject);
  /// ```
  ///
  /// ### Notes
  /// - Replacing the generator at runtime affects all threads that share this
  ///   mapper instance, so it should be done carefully in concurrent contexts.
  /// - Any features like `SerializationFeature.INDENT_OUTPUT` will still
  ///   apply to the new generator.
  void setJsonGenerator(JsonGenerator jsonGenerator);

  /// Assigns the active [SerializerProvider] to this component.
  ///
  /// The serializer provider is responsible for supplying and managing
  /// serializers used to convert Dart objects into JSON. This method allows
  /// the serialization subsystem to inject a provider configured with
  /// caching, naming strategies, and custom serializers.
  ///
  /// ### Parameters
  /// - [provider]: The [SerializerProvider] instance to associate with
  ///   the current serializer or converter.
  ///
  /// ### Example
  /// ```dart
  /// serializer.setSerializerProvider(provider);
  /// ```
  void setSerializerProvider(SerializerProvider provider);

  /// Assigns the active [DeserializationContext] to this component.
  ///
  /// The deserialization context carries configuration, metadata, and
  /// type information used during the process of converting JSON data
  /// into Dart objects. It manages reference resolution and error handling.
  ///
  /// ### Parameters
  /// - [context]: The [DeserializationContext] instance to associate
  ///   with this deserializer or converter.
  ///
  /// ### Example
  /// ```dart
  /// deserializer.setDeserializationContext(context);
  /// ```
  void setDeserializationContext(DeserializationContext context);

  // ─────────────────────────────────────────────────────────────
  // Feature Flags
  // ─────────────────────────────────────────────────────────────

  /// Enables a configurable feature flag in the mapping engine.
  ///
  /// Jetson supports feature toggles similar to Jackson's `SerializationFeature`
  /// and `DeserializationFeature` enums (e.g. `FAIL_ON_UNKNOWN_PROPERTIES`).
  ///
  /// ---
  void enableFeature(String featureName);

  /// Disables a configurable feature flag.
  ///
  /// ---
  void disableFeature(String featureName);

  /// Returns whether a given feature flag is currently enabled.
  ///
  /// ---
  bool isFeatureEnabled(String featureName);
}

/// Feature flags that influence **serialization behavior** in JetLeaf.
///
/// These options control how values, structures, and formatting are handled
/// when converting Dart objects into JSON output.
///
/// ### Example
/// ```dart
/// final mapper = ObjectMapper()
///   ..enable(SerializationFeature.INDENT_OUTPUT)
///   ..disable(SerializationFeature.WRITE_NULL_MAP_VALUES);
/// ```
///
/// ### Notes
/// - Features are toggled via [ObjectMapper.enable] / [ObjectMapper.disable].
/// - Default configuration is optimized for correctness and minimal output size.
///
/// ### See also
/// - [DeserializationFeature]
/// - [ObjectMapper]
enum SerializationFeature {
  /// Fails serialization when an empty object (with no writable properties)
  /// is encountered. Useful for strict schema validation.
  FAIL_ON_EMPTY,

  /// Serializes date and time values as **numeric timestamps** instead of
  /// ISO-8601 strings.
  ///
  /// When enabled, `DateTime(2025, 10, 28)` → `1730073600000`.
  WRITE_DATES_AS_TIMESTAMPS,

  /// Determines whether `null` entries in maps or fields should be written
  /// to the output JSON.
  ///
  /// - `true`: writes `"key": null`
  /// - `false`: omits the key entirely
  WRITE_NULL_MAP_VALUES,

  /// Enables human-readable, indented JSON output with line breaks.
  ///
  /// Useful for debugging, logging, or pretty-printed configuration files.
  INDENT_OUTPUT,

  /// Orders map entries by their keys in lexicographic order before writing.
  ///
  /// Ensures deterministic output for schema comparison and caching.
  ORDER_MAP_ENTRIES_BY_KEYS,

  /// Wraps the root value within an additional object named after its type.
  ///
  /// Example:
  /// ```json
  /// { "User": { "id": 1, "name": "Alice" } }
  /// ```
  WRAP_ROOT_VALUE,
}

/// Feature flags that influence **deserialization behavior** in JetLeaf.
///
/// These options determine how JSON input is interpreted, validated,
/// and transformed into Dart objects.
///
/// ### Example
/// ```dart
/// final mapper = ObjectMapper()
///   ..enable(DeserializationFeature.ACCEPT_EMPTY_STRINGS_AS_NULL)
///   ..disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
/// ```
///
/// ### Notes
/// - Features provide compatibility and fault-tolerance for varying JSON formats.
/// - Most options mirror Jackson’s configuration model for familiarity.
///
/// ### See also
/// - [SerializationFeature]
/// - [ObjectMapper]
enum DeserializationFeature {
  /// Throws an error when encountering unknown JSON properties
  /// that do not map to any field in the target class.
  FAIL_ON_UNKNOWN_PROPERTIES,

  /// Allows `//` and `/* */` comments inside JSON documents.
  ///
  /// Non-standard, but useful for configuration files or relaxed parsing.
  ALLOW_COMMENTS,

  /// Permits the use of single quotes (`'value'`) for strings
  /// in addition to standard double quotes.
  ALLOW_SINGLE_QUOTES,

  /// Fails when a required constructor or factory parameter
  /// (creator property) is missing from input JSON.
  FAIL_ON_MISSING_CREATOR_PROPERTIES,

  /// Interprets empty strings (`""`) as `null` for non-string fields.
  ///
  /// Example:
  /// ```json
  /// { "user": "" } → { "user": null }
  /// ```
  ACCEPT_EMPTY_STRINGS_AS_NULL,

  /// Adjusts parsed `DateTime` values to the context’s configured time zone
  /// (see [ObjectMapper.TIMEZONE_PROPERTY]).
  ADJUST_DATES_TO_CONTEXT_TIME_ZONE,
}

/// {@template naming_strategy}
/// Provides a unified interface for **field name transformation** between
/// Dart-style and JSON-style representations.
///
/// The [NamingStrategy] defines the transformation rules used to map
/// Dart identifiers (typically in `camelCase`) to JSON-compatible
/// names (such as `snake_case` or `kebab-case`) and back.
///
/// ### Overview
/// Implementations of this interface provide predictable and reversible
/// conversions between internal Dart field names and external JSON keys.
///
/// This is a **core abstraction** used by JetLeaf serialization systems
/// such as `JsonMapper`, `ObjectCodec`, and other reflection-based
/// adapters that require naming consistency.
///
/// ### Example
/// ```dart
/// final strategy = SnakeCaseNamingStrategy();
///
/// final jsonKey = strategy.toJsonName('userName'); // 'user_name'
/// final dartField = strategy.toDartName('user_name'); // 'userName'
/// ```
///
/// ### Common Strategies
/// - **Snake case** (`userName` → `user_name`)
/// - **Kebab case** (`userName` → `user-name`)
/// - **Pascal case** (`userName` → `UserName`)
///
/// ### Implementation Notes
/// - Implementations must be **deterministic** (same input yields same output)
/// - The transformation must be **reversible** (see [toDartName])
/// - Should handle **acronyms**, **numbers**, and **edge cases** gracefully
///
/// ### See also
/// - [toJsonName]
/// - [toDartName]
/// {@endtemplate}
abstract interface class NamingStrategy {
  /// Represents the [NamingStrategy] type for reflection and framework-level
  /// type resolution within the Jetson serialization system.
  ///
  /// This static [Class] reference allows runtime introspection and dynamic
  /// discovery of custom naming strategies (e.g., snake_case, camelCase).
  /// It enables the framework to identify parameters or components requiring
  /// a specific naming policy.
  static final Class<NamingStrategy> CLASS = Class<NamingStrategy>(null, PackageNames.JETSON);

  /// Converts a Dart field name into a JSON-compatible name.
  ///
  /// Called during **serialization** to transform `camelCase`
  /// identifiers into the desired JSON format.
  ///
  /// Example:
  /// ```dart
  /// toJsonName('userName'); // → user_name
  /// ```
  ///
  /// Implementations should ensure consistent, reversible transformations.
  String toJsonName(String name);

  /// Converts a JSON field name back into a Dart-compatible identifier.
  ///
  /// Called during **deserialization** to transform `snake_case` or
  /// `kebab-case` names into valid Dart field identifiers.
  ///
  /// Example:
  /// ```dart
  /// toDartName('user_name'); // → userName
  /// ```
  ///
  /// Should be the inverse of [toJsonName].
  String toDartName(String name);
}

/// {@template json_parser}
/// A **streaming JSON reader** that sequentially exposes parsed JSON tokens.
///
/// The [JsonParser] provides low-level, pull-based access to JSON input,
/// allowing deserializers to process data incrementally rather than loading
/// entire structures into memory.
///
/// ### Overview
/// - Reads from strings, byte streams, or other character sources  
/// - Emits tokens (`JsonToken`) as it parses  
/// - Allows skipping nested objects and arrays efficiently  
///
/// ### Example
/// ```dart
/// final parser = StringJsonParser('{"name": "Alice", "age": 30}');
/// while (parser.nextToken()) {
///   print(parser.getCurrentToken());
/// }
/// parser.close();
/// ```
///
/// ### Typical Usage
/// Implementations are primarily used internally by:
/// - `ObjectMapper` deserializers
/// - Custom JSON readers
/// - Streaming APIs where partial JSON reading is required
///
/// ### See also
/// - [JsonToken]
/// - [ObjectMapper]
/// - [JsonDeserializer]
/// - [Closeable]
/// {@endtemplate}
abstract interface class JsonParser implements Closeable {
  /// Represents the [JsonParser] type for reflection-based registration and
  /// dependency resolution.
  ///
  /// Used by the Jetson deserialization pipeline to dynamically recognize
  /// parser components responsible for reading structured JSON data from
  /// an input source (string, stream, etc.).
  static final Class<JsonParser> CLASS = Class<JsonParser>(null, PackageNames.JETSON);

  /// Advances the parser to the **next JSON token**.
  ///
  /// This method reads input until the next structural or value token is found.
  /// Returns `true` if another token exists, or `false` when the end of input
  /// is reached.
  ///
  /// ### Example
  /// ```dart
  /// while (parser.nextToken()) {
  ///   print(parser.getCurrentToken());
  /// }
  /// ```
  ///
  /// ### Notes
  /// - Tokens include object/array boundaries and scalar values  
  /// - After reaching the end, calling again should return `false`
  ///
  /// See also:
  /// - [getCurrentToken]
  bool nextToken();

  /// Returns the **current token type**, such as [JsonToken.startObject]
  /// or [JsonToken.VALUE_STRING].
  ///
  /// This indicates what kind of JSON element the parser is currently pointing to.
  ///
  /// ### Example
  /// ```dart
  /// if (parser.getCurrentToken() == JsonToken.FIELD_NAME) {
  ///   print('Field: ${parser.getCurrentName()}');
  /// }
  /// ```
  ///
  /// ### Notes
  /// - Always valid after a successful [nextToken] call  
  /// - May return `null` before the first token
  JsonToken? getCurrentToken();

  /// Returns the **current field name**, if the parser is positioned
  /// at a JSON object field.
  ///
  /// ### Example
  /// ```dart
  /// if (parser.getCurrentToken() == JsonToken.FIELD_NAME) {
  ///   print(parser.getCurrentName());
  /// }
  /// ```
  ///
  /// Returns `null` for tokens outside object field contexts.
  String? getCurrentName();

  /// Returns the **text or raw value** associated with the current token.
  ///
  /// For value tokens, this returns the token’s actual content, such as a string,
  /// number, or boolean. For non-value tokens (like `{` or `}`), it may return `null`.
  ///
  /// ### Example
  /// ```dart
  /// if (parser.getCurrentToken() == JsonToken.VALUE_STRING) {
  ///   print('Value: ${parser.getCurrentValue()}');
  /// }
  /// ```
  ///
  /// ### Notes
  /// - May return primitive types, strings, or `null`  
  /// - For number tokens, the type may depend on the parser implementation
  Object? getCurrentValue();

  /// Skips the **current nested structure**, such as an object or array.
  ///
  /// This allows parsers or deserializers to ignore sections of input
  /// without fully reading them.
  ///
  /// ### Example
  /// ```dart
  /// if (parser.getCurrentToken() == JsonToken.START_ARRAY) {
  ///   parser.skipChildren(); // skips the entire array
  /// }
  /// ```
  ///
  /// ### Notes
  /// - Must be called when positioned on a structural start token  
  /// - After skipping, the parser is positioned *after* the skipped structure
  void skipChildren();
}

/// Enumerates all **token types** that a [JsonParser] can encounter during
/// JSON parsing.
///
/// Tokens represent both **structural** and **value-level** elements within
/// a JSON document, enabling fine-grained parsing control.
///
/// ### Example
/// ```dart
/// if (parser.getCurrentToken() == JsonToken.VALUE_NUMBER) {
///   print('Found a number: ${parser.getCurrentValue()}');
/// }
/// ```
///
/// ### Categories
/// - **Structural tokens:** [START_OBJECT], [END_OBJECT], [START_ARRAY], [END_ARRAY]  
/// - **Field tokens:** [FIELD_NAME]  
/// - **Value tokens:** [VALUE_STRING], [VALUE_NUMBER], [VALUE_BOOLEAN], [VALUE_NULL]
///
/// See also:
/// - [JsonParser]
enum JsonToken {
  /// Indicates the beginning of a JSON object (`{`).
  START_OBJECT,

  /// Indicates the end of a JSON object (`}`).
  END_OBJECT,

  /// Indicates the beginning of a JSON array (`[`).
  START_ARRAY,

  /// Indicates the end of a JSON array (`]`).
  END_ARRAY,

  /// Represents a field name within a JSON object.
  FIELD_NAME,

  /// Represents a string value.
  VALUE_STRING,

  /// Represents a numeric value.
  VALUE_NUMBER,

  /// Represents a boolean value (`true` or `false`).
  VALUE_BOOLEAN,

  /// Represents a null literal (`null`).
  VALUE_NULL,
}

/// {@template json_generator}
/// A **streaming JSON writer** that outputs JSON tokens sequentially.
///
/// The [JsonGenerator] provides structured, incremental JSON output for
/// JetLeaf’s serialization engine. It supports object and array boundaries,
/// primitive values, and raw JSON injection for custom serialization cases.
///
/// ### Overview
/// - Produces syntactically valid JSON documents
/// - Supports streaming or in-memory output
/// - Typically used by [ObjectMapper] and custom serializers
///
/// ### Example
/// ```dart
/// final generator = StringJsonGenerator();
/// generator.writeStartObject();
/// generator.writeFieldName('name');
/// generator.writeString('Alice');
/// generator.writeFieldName('age');
/// generator.writeNumber(30);
/// generator.writeEndObject();
///
/// print(generator.toJsonString());
/// // Output: {"name":"Alice","age":30}
/// ```
///
/// ### See also
/// - [JsonParser]
/// - [ObjectMapper]
/// - [JsonSerializer]
/// {@endtemplate}
abstract interface class JsonGenerator {
  /// Represents the [JsonGenerator] type for reflection and dynamic discovery.
  ///
  /// This reference identifies components responsible for writing JSON data
  /// during serialization. It allows Jetson to register, configure, and
  /// customize output generators at runtime.
  static final Class<JsonGenerator> CLASS = Class<JsonGenerator>(null, PackageNames.JETSON);

  /// Writes the **start of a JSON object** (`{`).
  ///
  /// This opens a new object context. Every [writeStartObject] must be paired
  /// with a corresponding [writeEndObject].
  ///
  /// ### Example
  /// ```dart
  /// generator.writeStartObject();
  /// generator.writeFieldName('id');
  /// generator.writeNumber(42);
  /// generator.writeEndObject();
  /// ```
  ///
  /// ### Notes
  /// - Nested objects are supported  
  /// - Improper balancing may result in invalid JSON
  void writeStartObject();

  /// Writes the **end of the current JSON object** (`}`).
  ///
  /// Completes the current object scope opened by [writeStartObject].
  ///
  /// ### Example
  /// ```dart
  /// generator.writeStartObject();
  /// generator.writeFieldName('active');
  /// generator.writeBoolean(true);
  /// generator.writeEndObject();
  /// ```
  ///
  /// ### Notes
  /// - Should only be called after [writeStartObject]
  void writeEndObject();

  /// Writes the **start of a JSON array** (`[`).
  ///
  /// This opens an array scope, allowing multiple sequential value writes.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeStartArray();
  /// generator.writeString('A');
  /// generator.writeString('B');
  /// generator.writeEndArray();
  /// // ["A","B"]
  /// ```
  ///
  /// ### Notes
  /// - Must be closed by [writeEndArray]
  void writeStartArray();

  /// Writes the **end of a JSON array** (`]`).
  ///
  /// Completes the current array context opened by [writeStartArray].
  ///
  /// ### Example
  /// ```dart
  /// generator.writeStartArray();
  /// generator.writeNumber(1);
  /// generator.writeNumber(2);
  /// generator.writeEndArray();
  /// ```
  void writeEndArray();

  /// Writes a **field name** within an object context.
  ///
  /// This should precede the corresponding field value.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeStartObject();
  /// generator.writeFieldName('title');
  /// generator.writeString('JetLeaf');
  /// generator.writeEndObject();
  /// ```
  ///
  /// ### Notes
  /// - Must be inside an object  
  /// - Should not be called outside `{}` blocks
  void writeFieldName(String name);

  /// Writes a **string value**.
  ///
  /// Properly escapes quotation marks and control characters.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeString('Hello, World');
  /// // Output: "Hello, World"
  /// ```
  void writeString(String value);

  /// Writes a **numeric value**.
  ///
  /// Supports integers and floating-point numbers.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeNumber(3.14);
  /// // Output: 3.14
  /// ```
  void writeNumber(num value);

  /// Writes a **boolean value**.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeBoolean(false);
  /// // Output: false
  /// ```
  void writeBoolean(bool value);

  /// Writes a **null literal**.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeNull();
  /// // Output: null
  /// ```
  void writeNull();

  /// Writes a **raw JSON fragment** directly to output.
  ///
  /// This bypasses validation and escaping logic, allowing insertion
  /// of preformatted JSON content.
  ///
  /// ### ⚠️ Warning
  /// Use cautiously — malformed JSON fragments will corrupt the output stream.
  ///
  /// ### Example
  /// ```dart
  /// generator.writeRaw('"custom": {"nested": true}');
  /// ```
  ///
  /// ### Notes
  /// - Best used for embedding external JSON or advanced serializers
  void writeRaw(String json);

  /// Returns the **final JSON output string**, if the generator writes to an
  /// in-memory buffer.
  ///
  /// ### Example
  /// ```dart
  /// final json = generator.toJsonString();
  /// print(json);
  /// ```
  ///
  /// ### Notes
  /// - Not all implementations buffer output in memory (e.g., stream writers)  
  /// - May throw if not supported by the concrete implementation
  String toJsonString();
}

/// {@template serializer_provider}
/// Provides contextual access to serialization components used during
/// JSON serialization.
///
/// A [SerializerProvider] serves as the **context hub** for all serializer
/// operations in JetLeaf, managing references to the active [ObjectMapper],
/// [NamingStrategy], and [ConversionService]. It also locates and invokes
/// appropriate [JsonSerializer] implementations for specific types.
///
/// ### Overview
/// - Supplies serializers for complex or custom types  
/// - Provides naming and conversion utilities during field serialization  
/// - Ensures consistent configuration and feature handling across serializers
///
/// ### Example
/// ```dart
/// final serializer = provider.findSerializerForType(Class.of(User));
/// serializer?.serialize(user, generator, provider);
/// ```
///
/// ### See also
/// - [ObjectMapper]
/// - [JsonSerializer]
/// - [NamingStrategy]
/// - [ConversionService]
/// - [BaseSerializer]
/// {@endtemplate}
abstract interface class SerializerProvider implements BaseSerializer {
  /// Represents the [SerializerProvider] type for runtime reflection.
  ///
  /// Used internally by Jetson to manage and supply serializers for complex
  /// types, handling caching, configuration, and contextual serialization logic.
  static final Class<SerializerProvider> CLASS = Class<SerializerProvider>(null, PackageNames.JETSON);

  /// Finds and returns a **[JsonSerializer]** suitable for the given [type].
  ///
  /// Looks up registered serializers, falling back to default implementations
  /// if no explicit one is found.
  ///
  /// ### Example
  /// ```dart
  /// final serializer = provider.findSerializerForType(Class.of(User));
  /// serializer?.serialize(user, generator, provider);
  /// ```
  ///
  /// ### Notes
  /// - Returns `null` if no serializer is registered for the given type  
  /// - Used internally by [ObjectMapper] and nested serializers
  JsonSerializer? findSerializerForType(Class type);

  /// Serializes the given [object] using a registered or default serializer.
  ///
  /// This method provides a unified entry point for serializing arbitrary
  /// objects through the [SerializerProvider] context.
  ///
  /// ### Example
  /// ```dart
  /// provider.serialize(user, generator);
  /// ```
  ///
  /// ### Notes
  /// - Delegates to the appropriate [JsonSerializer]  
  /// - Writes output to the provided [JsonGenerator] 
  void serialize(Object? object, JsonGenerator generator);
}

/// {@template deserialization_context}
/// Provides contextual operations and configuration access for JSON → object
/// deserialization within the JetLeaf mapping system.
///
/// The [DeserializationContext] serves as the execution environment for
/// all [JsonDeserializer] instances, managing:
/// - Type resolution via [Class] metadata
/// - Parser-driven traversal through [JsonParser]
/// - Lookup of registered deserializers and converters
/// - Access to shared services like [ConversionService] and [NamingStrategy]
///
/// ### Purpose
/// This interface ensures consistent, reusable deserialization behavior
/// across all object mappers and data binding layers.
///
/// ### Example
/// ```dart
/// final deserializer = context.findDeserializerForType(Class.forType(User));
/// final user = context.deserialize<User>(parser, Class.forType(User));
/// ```
///
/// ### See also
/// - [JsonDeserializer]
/// - [JsonParser]
/// - [ObjectMapper]
/// - [ConversionService]
/// - [NamingStrategy]
/// {@endtemplate}
abstract interface class DeserializationContext implements BaseSerializer {
  /// Represents the [DeserializationContext] type for reflection and runtime
  /// discovery within the Jetson framework.
  ///
  /// Enables flexible management of state and configuration during JSON
  /// deserialization, including resolving object references, managing
  /// type adapters, and applying contextual settings.
  static final Class<DeserializationContext> CLASS = Class<DeserializationContext>(null, PackageNames.JETSON);

  /// Locates a registered [JsonDeserializer] capable of handling the given [type].
  ///
  /// This method queries the internal deserializer registry associated with
  /// the active [ObjectMapper]. If no custom deserializer is found, the
  /// framework attempts to provide a default handler.
  ///
  /// ### Example
  /// ```dart
  /// final deserializer = context.findDeserializerForType(Class.forType(User));
  /// if (deserializer != null) {
  ///   final user = deserializer.deserialize(parser, context);
  /// }
  /// ```
  ///
  /// ### Notes
  /// - Enables polymorphic and user-defined deserialization strategies  
  /// - Typically used internally by [ObjectMapper.readValue]  
  /// - Returns `null` if no compatible deserializer is registered
  JsonDeserializer? findDeserializerForType(Class type);

  /// Deserializes an object of type [T] from the current [JsonParser] state.
  ///
  /// This method delegates parsing to the appropriate [JsonDeserializer],
  /// which reconstructs the object from the token stream provided by [parser].
  ///
  /// ### Example
  /// ```dart
  /// final parser = JsonFactory.createParser(jsonString);
  /// final user = context.deserialize<User>(parser, Class.forType(User));
  /// ```
  ///
  /// ### Behavior
  /// - Traverses tokens from [JsonParser] in sequence  
  /// - Resolves nested objects, collections, and primitives recursively  
  /// - Uses [ConversionService] for scalar coercion and type adaptation  
  /// - Applies [NamingStrategy] for field name alignment
  ///
  /// ### Error Handling
  /// Throws an exception if:
  /// - The JSON structure is invalid or incomplete  
  /// - No compatible deserializer can be found for [type]
  ///
  /// ### See also
  /// - [JsonDeserializer.deserialize]
  /// - [ObjectMapper.readValue]
  T deserialize<T>(JsonParser parser, Class<T> type);
}

/// {@template json_serializable}
/// Marker interface for all Jetson JSON (de)serialization components.
///
/// This interface does not define any methods — it simply provides a
/// common type for all Jetson serialization-related classes:
///
/// - [JsonSerializer]
/// - [JsonDeserializer]
/// - [JsonConverterAdapter]
///
/// It serves a similar role to Jackson’s `JsonSerializable` marker,
/// allowing consistent registration, lookup, and configuration of
/// all JSON serialization participants.
///
/// {@endtemplate}
abstract interface class JsonSerializable {
  /// {@macro json_serializable}
  const JsonSerializable();
}

/// {@template json_serializer}
/// A type-specific serializer that converts Dart objects into JSON output.
///
/// The [JsonSerializer] defines how an object of type [T] should be transformed
/// into JSON tokens and written to the provided [JsonGenerator].
///
/// ### Purpose
/// - Provides fine-grained control over the serialization process  
/// - Integrates with [SerializerProvider] for naming strategies, converters,  
///   and object mapping configuration  
/// - Enables custom serialization for complex, nested, or annotated objects
///
/// ### Usage
/// Custom serializers can be registered using:
/// ```dart
/// objectMapper.registerSerializer(UserSerializer());
/// ```
///
/// ### Example
/// ```dart
/// final class UserSerializer extends JsonSerializer<User> {
///   const UserSerializer();
///
///   @override
///   void serialize(User value, JsonGenerator generator, SerializerProvider provider) {
///     generator.writeStartObject();
///     final naming = provider.getNamingStrategy();
///
///     generator.writeFieldName(naming.toJsonName('id'));
///     generator.writeNumber(value.id);
///
///     generator.writeFieldName(naming.toJsonName('name'));
///     generator.writeString(value.name);
///
///     generator.writeEndObject();
///   }
/// }
/// ```
///
/// ### See also
/// - [JsonGenerator]
/// - [SerializerProvider]
/// - [JsonDeserializer]
/// - [ObjectMapper]
/// {@endtemplate}
@Generic(JsonSerializer)
abstract interface class JsonSerializer<T> extends JsonSerializable implements ClassGettable<T> {
  /// Represents the [JsonSerializer] type for reflection and type resolution.
  ///
  /// Allows Jetson to dynamically locate, register, and apply serializers
  /// for specific Dart types when converting objects into JSON structures.
  static final Class<JsonSerializer> CLASS = Class<JsonSerializer>(null, PackageNames.JETSON);

  /// Creates a new [JsonSerializer].
  ///
  /// {@macro json_serializer}
  const JsonSerializer();

  /// Returns whether the given [type] can be **serialized** by the system.
  ///
  /// Implementations should determine if a registered serializer or converter
  /// exists for the specified class type [T].
  ///
  /// Returns:
  /// - `true` → if the type can be serialized into a transferable format (e.g., JSON).
  /// - `false` → if no compatible serializer is available.
  ///
  /// ### Example
  /// ```dart
  /// if (serializer.canSerialize(Class<User>)) {
  ///   final json = serializer.serialize(user);
  /// }
  /// ```
  bool canSerialize(Class type);

  /// Serializes an object of type [T] into JSON using the provided [JsonGenerator]
  /// and [SerializerProvider].
  ///
  /// Implementations should:
  /// - Write fields in the correct JSON structure using [generator]  
  /// - Apply the active [NamingStrategy] for key transformation  
  /// - Use the [SerializerProvider] for nested or custom serialization  
  ///
  /// ### Example
  /// ```dart
  /// serializer.serialize(user, generator, provider);
  /// final json = generator.toJsonString();
  /// print(json); // {"id":1,"name":"Alice"}
  /// ```
  ///
  /// ### Notes
  /// - Should write valid JSON output  
  /// - May recursively serialize nested objects  
  /// - Must maintain structural integrity of objects and collections
  ///
  /// ### Error Handling
  /// Implementations should throw descriptive errors if:
  /// - A required field cannot be serialized  
  /// - An unsupported type is encountered  
  /// - JSON structural consistency cannot be guaranteed
  ///
  /// ### See also
  /// - [JsonGenerator]
  /// - [SerializerProvider]
  /// - [JsonDeserializer]
  void serialize(T value, JsonGenerator generator, SerializerProvider serializer);
}

/// {@template json_deserializer}
/// A type-specific deserializer that converts JSON tokens into Dart objects.
///
/// The [JsonDeserializer] represents the core abstraction for reconstructing
/// typed Dart objects from a parsed JSON input stream. Implementations define
/// how a JSON structure is interpreted and mapped into model instances.
///
/// ### Purpose
/// - Defines how objects of type [T] are reconstructed from JSON  
/// - Bridges the [JsonParser] token stream and Dart object creation  
/// - Integrates with [DeserializationContext] for dependency and type access
///
/// ### Usage
/// Custom deserializers can be registered via [ObjectMapper.registerDeserializer]
/// or bundled inside JetLeaf modules.
///
/// ### Example
/// ```dart
/// final class UserDeserializer extends JsonDeserializer<User> {
///   const UserDeserializer();
///
///   @override
///   User? deserialize(JsonParser parser, DeserializationContext ctxt) {
///     final map = ctxt.getObjectMapper().readValueFromMap<Map<String, dynamic>>(
///       parser.getCurrentValue() as Map<String, dynamic>,
///       Class.forType(Map),
///     );
///     return User(
///       id: map['id'],
///       name: map['name'],
///     );
///   }
/// }
/// ```
///
/// ### See also
/// - [JsonParser]
/// - [DeserializationContext]
/// - [ObjectMapper]
/// - [JsonSerializer]
/// {@endtemplate}
@Generic(JsonDeserializer)
abstract interface class JsonDeserializer<T> extends JsonSerializable implements ClassGettable<T> {
  /// Represents the [JsonDeserializer] type for reflection-based discovery.
  ///
  /// Provides the framework with the ability to map JSON structures back into
  /// Dart objects using registered or inferred deserializers.
  static final Class<JsonDeserializer> CLASS = Class<JsonDeserializer>(null, PackageNames.JETSON);

  /// Creates a new [JsonDeserializer].
  ///
  /// {@macro json_deserializer}
  const JsonDeserializer();

  /// Returns whether the given [type] can be **deserialized** by the system.
  ///
  /// Implementations should determine if a registered deserializer or converter
  /// exists for the specified class type [T].
  ///
  /// Returns:
  /// - `true` → if the type can be deserialized into an object instance.
  /// - `false` → if no compatible deserializer is available.
  ///
  /// ### Example
  /// ```dart
  /// if (serializer.canDeserialize(Class<User>)) {
  ///   final user = serializer.deserialize(json, Class<User>());
  /// }
  /// ```
  bool canDeserialize(Class type);

  /// Deserializes an object of type [T] using the given [JsonParser] and
  /// [DeserializationContext].
  ///
  /// This method reads tokens from the provided [parser], interprets them
  /// according to the target type metadata, and reconstructs an instance
  /// of [T].
  ///
  /// ### Example
  /// ```dart
  /// final user = UserDeserializer().deserialize(parser, context);
  /// ```
  ///
  /// ### Responsibilities
  /// - Interpret JSON tokens from the parser sequentially  
  /// - Use [DeserializationContext] for nested deserialization and converters  
  /// - Handle complex object graphs, lists, and maps recursively  
  /// - Return a fully reconstructed object of type [T]
  ///
  /// ### Error Handling
  /// Should throw a descriptive exception if:
  /// - JSON structure mismatches the expected type  
  /// - Required fields are missing or invalid  
  /// - Type conversion fails during object creation
  ///
  /// ### See also
  /// - [DeserializationContext]
  /// - [JsonParser]
  /// - [ObjectMapper.readValue]
  T? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass);
}

/// {@template json_converter_adapter}
/// A **bidirectional JSON converter** that implements both
/// [JsonSerializer] and [JsonDeserializer] for type [T].
///
/// The [JsonConverterAdapter] provides a unified way to serialize and
/// deserialize objects of type [T], ensuring consistent logic in both
/// directions.
///
/// ### Purpose
/// - Encapsulates both serialization and deserialization for a type  
/// - Simplifies registration of custom adapters via [ObjectMapper.registerAdapter]  
/// - Ensures symmetrical conversion between JSON and Dart models
///
/// ### Example
/// ```dart
/// final class DateTimeAdapter extends JsonConverterAdapter<DateTime> {
///   const DateTimeAdapter();
///
///   @override
///   void serialize(DateTime value, JsonGenerator generator, SerializerProvider provider) {
///     generator.writeString(value.toIso8601String());
///   }
///
///   @override
///   DateTime? deserialize(JsonParser parser, DeserializationContext ctxt) {
///     final raw = parser.getCurrentValue() as String;
///     return DateTime.parse(raw);
///   }
/// }
///
/// // Registration
/// objectMapper.registerAdapter(const DateTimeAdapter());
/// ```
///
/// ### Notes
/// - Typically used for primitive or lightweight types (e.g., DateTime, UUID)
/// - Adapters are reusable across multiple mappers  
/// - Both methods must be deterministic and symmetrical  
///
/// ### See also
/// - [JsonSerializer]
/// - [JsonDeserializer]
/// - [ObjectMapper]
/// - [DeserializationContext]
/// - [SerializerProvider]
/// {@endtemplate}
@Generic(JsonConverterAdapter)
abstract interface class JsonConverterAdapter<T> extends JsonSerializable implements JsonSerializer<T>, JsonDeserializer<T> {
  /// Represents the [JsonConverterAdapter] type for reflection and integration.
  ///
  /// This reference enables Jetson to detect and apply converters that bridge
  /// JSON serialization/deserialization logic to other frameworks or data
  /// formats (e.g., XML, BSON, YAML).
  static final Class<JsonConverterAdapter> CLASS = Class<JsonConverterAdapter>(null, PackageNames.JETSON);

  /// Creates a new bidirectional JSON converter for type [T].
  ///
  /// {@macro json_converter_adapter}
  const JsonConverterAdapter();
}