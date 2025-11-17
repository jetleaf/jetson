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

import 'package:jetleaf_core/context.dart';
import 'package:jetleaf_lang/lang.dart';

import '../base.dart';

/// {@template datetime_json_converter_adapter}
/// A **bidirectional JSON converter** for Dart [DateTime] objects.
///
/// The [DateTimeJsonConverterAdapter] serializes [DateTime] values into
/// ISO-8601–formatted strings and deserializes them back into [DateTime]
/// instances. It supports timezone resolution via the JetLeaf
/// [Environment] and [ObjectMapper] configuration.
///
/// ### Purpose
/// - Ensures consistent [DateTime] serialization across systems  
/// - Provides optional timezone-aware formatting  
/// - Implements both [JsonSerializer] and [JsonDeserializer] interfaces  
///
/// ### Timezone Resolution
/// The adapter looks up timezone settings in order of precedence:
/// 1. `ObjectMapper.TIMEZONE_PROPERTY`  
/// 2. `AbstractApplicationContext.APPLICATION_TIMEZONE`  
///
/// If no timezone is configured, the adapter defaults to UTC serialization.
///
/// ### Example
/// ```dart
/// final adapter = const DateTimeJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(DateTime.now(), generator, provider);
/// print(generator.toJsonString()); // "2025-10-28T14:33:21.000Z"
///
/// // Deserialization
/// final parser = JsonStringReader('"2025-10-28T14:33:21Z"');
/// final date = adapter.deserialize(parser, ctxt);
/// print(date); // 2025-10-28 14:33:21.000Z
/// ```
///
/// ### Notes
/// - Falls back to UTC when no timezone is configured  
/// - Converts zoned values using [ZonedDateTime] and [ZoneId]  
/// - Throws [InvalidFormatException] for non-string or malformed input  
///
/// ### See also
/// - [JsonConverterAdapter]
/// - [ZonedDateTime]
/// - [ObjectMapper]
/// - [DeserializationContext]
/// {@endtemplate}
final class DateTimeJsonConverterAdapter implements JsonConverterAdapter<DateTime> {
  /// Creates a new [DateTimeJsonConverterAdapter].
  ///
  /// {@macro datetime_json_converter_adapter}
  const DateTimeJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<DateTime>() || type.getType() == DateTime;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  void serialize(DateTime value, JsonGenerator generator, SerializerProvider serializer) {
    final timezone = serializer.getEnvironment().getProperty(ObjectMapper.TIMEZONE_PROPERTY)
      ?? serializer.getEnvironment().getProperty(AbstractApplicationContext.APPLICATION_TIMEZONE);

    if (timezone != null) {
      generator.writeString(ZonedDateTime.fromDateTime(value, ZoneId.of(timezone)).toString());
    } else {
      generator.writeString(value.toUtc().toIso8601String());
    }
  }

  @override
  DateTime? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();

    if (raw == null) {
      return null;
    }

    final timezone = ctxt.getEnvironment().getProperty(ObjectMapper.TIMEZONE_PROPERTY)
      ?? ctxt.getEnvironment().getProperty(AbstractApplicationContext.APPLICATION_TIMEZONE);

    if (raw is String) {
      if (timezone != null) {
        return ZonedDateTime.fromDateTime(DateTime.parse(raw), ZoneId.of(timezone)).toDateTime();
      }

      return DateTime.parse(raw).toLocal();
    }

    throw InvalidFormatException('Expected ISO8601 string for DateTime, got $raw');
  }

  @override
  Class<DateTime> toClass() => Class<DateTime>(null, PackageNames.DART);
}