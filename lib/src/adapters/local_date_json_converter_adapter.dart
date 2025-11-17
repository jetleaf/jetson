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

/// {@template local_date_json_converter_adapter}
/// A **bidirectional JSON converter** for [LocalDate] values.
///
/// The [LocalDateJsonConverterAdapter] handles the conversion between Dart
/// [LocalDate] objects and their ISO-8601 date string equivalents. It supports
/// serialization and deserialization of calendar dates without time or
/// timezone information.
///
/// ### Purpose
/// - Provides date-only JSON representation (`YYYY-MM-DD`)
/// - Ensures clean interoperability between Dart and external JSON systems  
/// - Omits time and timezone complexity for domain-driven calendar models
///
/// ### Format
/// Serialized output follows the ISO-8601 date format:
/// ```text
/// 2025-10-28
/// ```
///
/// ### Example
/// ```dart
/// final adapter = const LocalDateJsonConverterAdapter();
///
/// // Serialization
/// final generator = JsonStringWriter();
/// adapter.serialize(LocalDate.parse('2025-10-28'), generator, provider);
/// print(generator.toJsonString()); // "2025-10-28"
///
/// // Deserialization
/// final parser = JsonStringReader('"2025-10-28"');
/// final date = adapter.deserialize(parser, ctxt);
/// print(date); // LocalDate(2025-10-28)
/// ```
///
/// ### Notes
/// - Expects ISO-8601 compliant strings (YYYY-MM-DD)  
/// - Throws [InvalidFormatException] if a non-string or malformed value is encountered  
/// - Does **not** perform timezone or time conversion  
///
/// ### See also
/// - [LocalDateTimeJsonConverterAdapter]
/// - [ZonedDateTimeJsonConverterAdapter]
/// - [JsonConverterAdapter]
/// - [LocalDate]
/// {@endtemplate}
final class LocalDateJsonConverterAdapter implements JsonConverterAdapter<LocalDate> {
  /// Creates a new [LocalDateJsonConverterAdapter].
  ///
  /// {@macro local_date_json_converter_adapter}
  const LocalDateJsonConverterAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<LocalDate>() || type.getType() == LocalDate;

  @override
  bool canSerialize(Class type) => canDeserialize(type);

  @override
  LocalDate? deserialize(JsonParser parser, DeserializationContext ctxt, Class toClass) {
    final raw = parser.getCurrentValue();

    if (raw == null) {
      return null;
    }

    if (raw is String) {
      return LocalDate.parse(raw);
    }

    throw InvalidFormatException('Invalid LocalDate format. Expected ISO-8601 (e.g. "2025-10-28") but received $raw');
  }

  @override
  void serialize(LocalDate value, JsonGenerator generator, SerializerProvider serializer) {
    // Writes the LocalDate as an ISO-8601 string, e.g. "2025-10-28"
    generator.writeString(value.toString());
  }

  @override
  Class<LocalDate> toClass() => Class<LocalDate>(null, PackageNames.LANG);
}