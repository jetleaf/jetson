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

/// {@template local_datetime_json_converter_adapter}
/// A **bidirectional JSON converter** for [LocalDateTime] values.
///
/// The [LocalDateTimeJsonConverterAdapter] handles conversion between Dart
/// [LocalDateTime] objects and their ISO-8601 formatted string equivalents.
/// Unlike [ZonedDateTimeJsonConverterAdapter], this adapter does not apply
/// timezone context, focusing instead on the raw local date and time.
///
/// ### Purpose
/// - Enables local date–time serialization without timezone offsets  
/// - Supports standard ISO-8601 textual formats  
/// - Simplifies persistence of local timestamps within JSON documents  
///
/// ### Format
/// Serialized output follows ISO-8601 patterns such as:
/// ```text
/// 2025-06-27T08:15:30.123
/// ```
///
/// ### Example
/// ```dart
/// final adapter = const LocalDateTimeJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(LocalDateTime.now(), generator, provider);
/// print(generator.toJsonString());
/// // "2025-06-27T08:15:30.123"
///
/// // Deserialization
/// final parser = JsonStringReader('"2025-06-27T08:15:30.123"');
/// final dateTime = adapter.deserialize(parser, ctxt);
/// print(dateTime); // LocalDateTime instance
/// ```
///
/// ### Notes
/// - Expects ISO-8601 compliant strings without timezone components  
/// - Throws [InvalidFormatException] if a non-string or malformed value is encountered  
/// - Does not consult environment timezone properties  
///
/// ### See also
/// - [JsonConverterAdapter]
/// - [LocalDateTime]
/// - [ZonedDateTimeJsonConverterAdapter]
/// - [DateTimeJsonConverterAdapter]
/// {@endtemplate}
final class LocalDateTimeJsonConverterAdapter implements JsonConverterAdapter<LocalDateTime> {
  /// Creates a new [LocalDateTimeJsonConverterAdapter].
  ///
  /// {@macro local_datetime_json_converter_adapter}
  const LocalDateTimeJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<LocalDateTime>() || type.getType() == LocalDateTime;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  void serialize(LocalDateTime value, JsonGenerator generator, SerializerProvider serializer) {
    generator.writeString(value.toString());
  }

  @override
  LocalDateTime? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();

    if (raw == null) {
      return null;
    }

    if (raw is String) {
      return LocalDateTime.parse(raw);
    }

    throw InvalidFormatException(
      'Cannot deserialize LocalDateTime: expected a zoned ISO-8601 formatted string '
      '(e.g. "2025-06-27T08:15:30.123"), '
      'but received value "$raw" of type ${raw.runtimeType}.'
    );
  }

  @override
  Class<LocalDateTime> toClass() => Class<LocalDateTime>(null, PackageNames.LANG);
}