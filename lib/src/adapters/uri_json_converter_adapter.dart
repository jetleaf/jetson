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

/// {@template uri_json_converter_adapter}
/// A **bidirectional JSON converter** for Dart's [Uri] type.
///
/// The [UriJsonConverterAdapter] provides conversion between [Uri] instances
/// and their string representations in JSON.  
/// It ensures safe, standards-compliant handling of URIs according to
/// RFC 3986 while maintaining Dart-native parsing semantics.
///
/// ### Purpose
/// - Serializes [Uri] objects into JSON strings  
/// - Deserializes JSON string values into [Uri] instances  
/// - Guarantees portability across services that expect URI-encoded data
///
/// ### Format
/// Serialized output example:
/// ```json
/// "https://example.com/api/users?id=42"
/// ```
///
/// ### Example
/// ```dart
/// final adapter = const UriJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(Uri.parse('https://hapnium.com/docs'), generator, provider);
/// print(generator.toJsonString()); // "https://hapnium.com/docs"
///
/// // Deserialization
/// final parser = JsonStringReader('"https://hapnium.com/docs"');
/// final uri = adapter.deserialize(parser, ctxt);
/// print(uri); // Uri.parse("https://hapnium.com/docs")
/// ```
///
/// ### Notes
/// - Expects a valid URI string; malformed values throw [FormatException]  
/// - Returns `null` if the parsed JSON value is `null`  
/// - Uses Dart’s native [Uri.parse] for strict URI validation  
///
/// ### See also
/// - [JsonConverterAdapter]
/// - [DurationJsonConverterAdapter]
/// - [LocalDateJsonConverterAdapter]
/// - [Uri]
/// {@endtemplate}
final class UriJsonConverterAdapter implements JsonConverterAdapter<Uri> {
  /// {@macro uri_json_converter_adapter}
  const UriJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<Uri>() || type.getType() == Uri;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  void serialize(Uri value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeString(value.toString());
  }

  @override
  Uri? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();
    
    if (raw == null) {
      return null;
    }

    if (raw is String) {
      return Uri.parse(raw);
    }

    throw FormatException('Expected string value for Uri, got $raw');
  }

  @override
  Class<Uri> toClass() => Class<Uri>(null, PackageNames.DART);
}