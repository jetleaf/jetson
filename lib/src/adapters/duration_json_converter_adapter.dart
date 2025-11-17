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

/// {@template duration_json_converter_adapter}
/// A **bidirectional JSON converter** for Dart's [Duration] type.
///
/// The [DurationJsonConverterAdapter] serializes [Duration] instances into
/// numeric JSON values representing **microseconds**, and deserializes them
/// back into strongly-typed [Duration] objects.
///
/// ### Purpose
/// - Provides consistent, numeric-based duration encoding  
/// - Enables high-precision interval serialization for time calculations  
/// - Maintains microsecond accuracy during conversion
///
/// ### Format
/// Serialized output represents the duration length in microseconds:
/// ```json
/// 1500000
/// ```
///
/// ### Example
/// ```dart
/// final adapter = const DurationJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(const Duration(seconds: 1, microseconds: 500000), generator, provider);
/// print(generator.toJsonString()); // 1500000
///
/// // Deserialization
/// final parser = JsonStringReader('1500000');
/// final duration = adapter.deserialize(parser, ctxt);
/// print(duration); // Duration(microseconds: 1500000)
/// ```
///
/// ### Notes
/// - Expects a numeric JSON value representing **microseconds**
/// - Returns `null` if the parsed value is `null`
/// - Throws [InvalidFormatException] if the input is non-numeric  
///
/// ### See also
/// - [JsonConverterAdapter]
/// - [ZonedDateTimeJsonConverterAdapter]
/// - [LocalDateTimeJsonConverterAdapter]
/// - [Duration]
/// {@endtemplate}
final class DurationJsonConverterAdapter implements JsonConverterAdapter<Duration> {
  /// {@macro duration_json_converter_adapter}
  const DurationJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<Duration>() || type.getType() == Duration;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  void serialize(Duration value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeNumber(value.inMicroseconds);
  }

  @override
  Duration? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();

    if (raw == null) {
      return null;
    }

    if (raw is num) {
      return Duration(microseconds: raw.toInt());
    }

    throw InvalidFormatException('Expected numeric value for Duration, got $raw');
  }

  @override
  Class<Duration> toClass() => Class<Duration>(null, PackageNames.DART);
}