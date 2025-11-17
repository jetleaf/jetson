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

/// {@template url_json_converter_adapter}
/// A **bidirectional JSON converter** for JetLeaf’s [Url] type.
///
/// The [UrlJsonConverterAdapter] converts [Url] objects to and from their
/// string representations in JSON, ensuring reliable interoperability between
/// Dart’s [Uri] system and JetLeaf’s higher-level [Url] abstraction.
///
/// ### Purpose
/// - Serializes [Url] instances into JSON strings  
/// - Deserializes string values into [Url] objects  
/// - Enables consistent URL handling in distributed or web-integrated systems
///
/// ### Format
/// Serialized JSON example:
/// ```json
/// "https://api.hapnium.com/v1/resources"
/// ```
///
/// ### Example
/// ```dart
/// final adapter = const UrlJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(Url.parse('https://jetleaf.dev/api'), generator, provider);
/// print(generator.toJsonString()); // "https://jetleaf.dev/api"
///
/// // Deserialization
/// final parser = JsonStringReader('"https://jetleaf.dev/api"');
/// final url = adapter.deserialize(parser, ctxt);
/// print(url); // Url.parse("https://jetleaf.dev/api")
/// ```
///
/// ### Notes
/// - Expects a valid URL string; malformed inputs throw [FormatException]  
/// - Returns `null` when encountering a `null` JSON value  
/// - Relies on [Uri.parse] followed by `.toUrl()` conversion for accuracy  
///
/// ### See also
/// - [JsonConverterAdapter]
/// - [UriJsonConverterAdapter]
/// - [ObjectMapper]
/// - [Url]
/// {@endtemplate}
final class UrlJsonConverterAdapter implements JsonConverterAdapter<Url> {
  /// {@macro url_json_converter_adapter}
  const UrlJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<Uri>() || type.getType() == Uri;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  void serialize(Url value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeString(value.toString());
  }

  @override
  Url? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();
    
    if (raw == null) {
      return null;
    }

    if (raw is String) {
      return Uri.parse(raw).toUrl();
    }

    throw FormatException('Expected string value for Url, got $raw');
  }

  @override
  Class<Url> toClass() => Class<Url>(null, PackageNames.LANG);
}