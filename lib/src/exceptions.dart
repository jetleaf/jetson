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

import 'yaml/parser/yaml_scanner.dart';

/// {@template json_parsing_exception}
/// Thrown when a JSON input cannot be parsed or is syntactically invalid.
///
/// Used internally by JetLeaf's [JsonParser] implementations to signal
/// malformed JSON, unexpected tokens, or invalid input streams.
///
/// ### Example
/// ```dart
/// try {
///   final parser = StringJsonParser('{"incomplete": true');
///   parser.nextToken(); // throws JsonParsingException
/// } on JsonParsingException catch (e) {
///   print('Invalid JSON: ${e.message}');
/// }
/// ```
///
/// ### See also
/// - [JsonParser]
/// - [InvalidFormatException]
/// - [ObjectMapper]
/// 
/// {@endtemplate}
class JsonParsingException extends RuntimeException {
  /// Creates a new [JsonParsingException] with an error [message] and
  /// optional [cause].
  /// 
  /// {@macro json_parsing_exception}
  JsonParsingException(super.message, {super.cause});
}

/// {@template malformed_json_exception}
/// Thrown when JSON data is structurally invalid or fails validation.
///
/// This exception is raised by validation utilities or serializers when:
/// - JSON structure is broken (mismatched braces/brackets)
/// - Required fields are missing or malformed
/// - JSON doesn't match expected schema or object structure
///
/// ### Example
/// ```dart
/// try {
///   final validator = JsonValidator();
///   validator.validate('{"incomplete": true', schema: User);
/// } on MalformedJsonException catch (e) {
///   print('Validation failed: ${e.message}');
/// }
/// ```
///
/// ### See also
/// - [JsonValidator]
/// - [JsonParsingException]
/// {@endtemplate}
class MalformedJsonException extends RuntimeException {
  /// Creates a new [MalformedJsonException] with an error [message] and
  /// optional [cause].
  ///
  /// {@macro malformed_json_exception}
  MalformedJsonException(super.message, {super.cause});
}

/// {@template jetleaf_illegal_object_token_exception}
/// Thrown when a parser encounters an **illegal or unexpected token** while
/// reading an object structure (JSON, YAML, XML, etc.).
///
/// Common causes:
/// - Malformed or truncated input  
/// - Structural mismatch (e.g., expected a mapping key but found a value)  
/// - Unexpected token in the current parsing context
///
/// ### Usage
/// ```dart
/// throw IllegalObjectTokenException(
///   'Expected a mapping key but found a sequence indicator at line 3.',
/// );
/// ```
///
/// ### See also
/// - [ObjectGeneratorException]
/// - Jetson parsers such as `JsonParser`, `YamlParser`, etc.
/// {@endtemplate}
class IllegalObjectTokenException extends RuntimeException {
  /// {@macro jetleaf_illegal_object_token_exception}
  IllegalObjectTokenException(super.message);
}

/// {@template jetleaf_object_generator_exception}
/// Thrown when a generator fails to serialize an object structure into an
/// output format (JSON, YAML, XML, etc.).
///
/// This exception indicates generator-phase failures such as:
/// - Unsupported value types encountered during serialization  
/// - Structural inconsistencies while emitting output (e.g., writing a value
///   outside of a mapping)  
/// - Invalid generator state or API misuse
///
/// ### Usage
/// ```dart
/// throw ObjectGeneratorException(
///   'Attempted to write a value outside a mapping context.',
/// );
/// ```
///
/// ### Notes
/// - General-purpose exception for generator failures across formats.  
/// - Consider using more specific subclasses if you want format-specific errors.
/// {@endtemplate}
class ObjectGeneratorException extends RuntimeException {
  /// {@macro jetleaf_object_generator_exception}
  ObjectGeneratorException(super.message);
}

/// {@template jetson_no_deserializer_found_exception}
/// Thrown when Jetson cannot locate a **deserializer** capable of converting
/// input data (JSON, YAML, XML, etc.) into an object of the requested type.
///
/// This typically occurs when:
/// - No `ObjectDeserializer<T>` is registered for the target type  
/// - The target type lacks Jetson metadata or annotations required for
///   reflective construction  
/// - A custom converter was expected but not provided  
///
/// ### Example
/// ```dart
/// throw NoDeserializerFoundException(
///   'No deserializer found for type User.',
/// );
/// ```
///
/// ### See also
/// - [NoSerializerFoundException]
/// - [ObjectDeserializer]
/// - [ObjectMapper]
/// {@endtemplate}
class NoDeserializerFoundException extends RuntimeException {
  /// {@macro jetson_no_deserializer_found_exception}
  NoDeserializerFoundException(super.message);
}

/// {@template jetson_no_serializer_found_exception}
/// Thrown when Jetson cannot locate a **serializer** capable of converting
/// a Dart object into an output format (JSON, YAML, XML, etc.).
///
/// This typically occurs when:
/// - No `ObjectSerializer<T>` is registered for the object's type  
/// - The type lacks Jetson annotations or reflection metadata  
/// - A required `JsonConverterAdapter` / format-specific converter
///   is not configured  
///
/// ### Example
/// ```dart
/// throw NoSerializerFoundException(
///   'No serializer found for type Order.',
/// );
/// ```
///
/// ### See also
/// - [NoDeserializerFoundException]
/// - [ObjectSerializer]
/// - [ObjectMapper]
/// {@endtemplate}
class NoSerializerFoundException extends RuntimeException {
  /// {@macro jetson_no_serializer_found_exception}
  NoSerializerFoundException(super.message);
}

/// Exception thrown when a YAML parsing error occurs.
class YamlException extends RuntimeException {
  /// The position in the source where the error occurred.
  final YamlPosition position;
  
  /// Creates a new [YamlException] with the given [message] and [position].
  YamlException(super.message, this.position, {super.stackTrace});
  
  @override
  String toString() => 'YAML Exception at $position: $message';
}

/// Exception thrown when a YAML document contains an unsupported feature.
class UnsupportedYamlFeatureException extends YamlException {
  /// The unsupported feature name.
  final String feature;
  
  /// Creates a new [UnsupportedYamlFeatureException] for the given [feature].
  UnsupportedYamlFeatureException(this.feature, YamlPosition position, [StackTrace? stackTrace])
      : super('Unsupported YAML feature: $feature', position, stackTrace: stackTrace);
}

/// Exception thrown when a YAML document contains invalid syntax.
class YamlSyntaxException extends YamlException {
  /// Creates a new [YamlSyntaxException] with the given [message].
  YamlSyntaxException(String message, YamlPosition position, [StackTrace? stackTrace])
      : super('Syntax error: $message', position, stackTrace: stackTrace);
}