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

/// {@template jetson_object_mapper_type}
/// Specifies the **data format** handled by a particular [ObjectMapper]
/// instance.
///
/// Jetson supports multiple serialization formats, and each implementation
/// of [ObjectMapper] is associated with exactly one of these types.
///
/// This enum is used internally by Jetson to:
/// - Select the correct generator and parser (e.g., `JsonGenerator`, `YamlParser`)
/// - Determine which serializer/deserializer pairs to apply
/// - Drive format-specific configuration and feature flags
///
/// Applications may also use it when constructing or selecting mappers
/// dynamically (e.g., switching between JSON and YAML output).
///
/// ### Example
/// ```dart
/// final mapper = JetsonObjectMapper.forType(ObjectMapperType.JSON);
/// print(mapper.type); // ObjectMapperType.JSON
/// ```
///
/// ### Formats
/// - **JSON** — Standard JavaScript Object Notation  
/// - **XML** — Extensible Markup Language  
/// - **YAML** — YAML Ain’t Markup Language  
///
/// {@endtemplate}
enum ObjectMapperType {
  /// {@macro jetson_object_mapper_type}
  JSON,

  /// {@macro jetson_object_mapper_type}
  XML,

  /// {@macro jetson_object_mapper_type}
  YAML,
}