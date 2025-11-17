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

/// {@template zoned_datetime_json_converter_adapter}
/// A **bidirectional JSON converter** for [ZonedDateTime] objects.
///
/// The [ZonedDateTimeJsonConverterAdapter] provides full conversion between
/// Dart [ZonedDateTime] instances and their ISO-8601 JSON string
/// representations, optionally respecting global timezone configuration
/// through the JetLeaf [Environment].
///
/// ### Purpose
/// - Enables serialization of [ZonedDateTime] into a canonical string form  
/// - Deserializes ISO-8601 strings with or without explicit zone offsets  
/// - Respects environment-defined timezones for contextual consistency  
///
/// ### Timezone Resolution
/// The converter checks environment properties in order:
/// 1. `ObjectMapper.TIMEZONE_PROPERTY`  
/// 2. `AbstractApplicationContext.APPLICATION_TIMEZONE`  
///
/// When a timezone is defined, parsing and serialization are aligned to that
/// context. Otherwise, the adapter preserves the embedded timezone of the
/// [ZonedDateTime] instance.
///
/// ### Example
/// ```dart
/// final adapter = const ZonedDateTimeJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(
///   ZonedDateTime.fromDateTime(DateTime.now(), ZoneId.of('America/New_York')),
///   generator,
///   provider,
/// );
/// print(generator.toJsonString());
/// // "2025-10-28T10:45:00-04:00[America/New_York]"
///
/// // Deserialization
/// final parser = JsonStringReader('"2025-10-28T10:45:00-04:00[America/New_York]"');
/// final zoned = adapter.deserialize(parser, ctxt);
/// print(zoned.zone.id); // America/New_York
/// ```
///
/// ### Notes
/// - Accepts ISO-8601 formatted strings with or without explicit zone IDs  
/// - Honors configured environment timezone overrides  
/// - Throws [InvalidFormatException] for malformed or non-string values  
///
/// ### Error Handling
/// Throws:
/// - [InvalidFormatException] when JSON input is not a valid zoned string  
/// - Generic format errors are accompanied by detailed type info  
///
/// ### See also
/// - [JsonConverterAdapter]
/// - [ZonedDateTime]
/// - [ZoneId]
/// - [DateTimeJsonConverterAdapter]
/// - [ObjectMapper]
/// {@endtemplate}
final class ZonedDateTimeJsonConverterAdapter implements JsonConverterAdapter<ZonedDateTime> {
  /// Creates a new [ZonedDateTimeJsonConverterAdapter].
  ///
  /// {@macro zoned_datetime_json_converter_adapter}
  const ZonedDateTimeJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<ZonedDateTime>() || type.getType() == ZonedDateTime;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  void serialize(ZonedDateTime value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeString(value.toString());
  }

  @override
  ZonedDateTime? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();

    if (raw == null) {
      return null;
    }

    final timezone = ctxt.getEnvironment().getProperty(ObjectMapper.TIMEZONE_PROPERTY)
      ?? ctxt.getEnvironment().getProperty(AbstractApplicationContext.APPLICATION_TIMEZONE);

    if (raw is String) {
      if (timezone != null) {
        return ZonedDateTime.fromDateTime(DateTime.parse(raw), ZoneId.of(timezone));
      }

      return ZonedDateTime.parse(raw);
    }

    throw InvalidFormatException(
      'Cannot deserialize ZonedDateTime: expected a zoned ISO-8601 formatted string '
      '(e.g. "2023-12-25T15:30:45-05:00[America/New_York]"), '
      'but received value "$raw" of type ${raw.runtimeType}.'
    );
  }

  @override
  Class<ZonedDateTime> toClass() => Class<ZonedDateTime>(null, PackageNames.LANG);
}