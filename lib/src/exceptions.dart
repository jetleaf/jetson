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