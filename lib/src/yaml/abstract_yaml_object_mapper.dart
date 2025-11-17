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
import '../xml/abstract_xml_object_mapper.dart';
import 'yaml_object_mapper.dart' as yaml_mapper;

/// {@template abstract_yaml_object_mapper}
/// Abstract base implementation of [yaml_mapper.YamlObjectMapper] extending
/// [AbstractXmlObjectMapper] to provide YAML-specific serialization/deserialization.
///
/// This class implements all [yaml_mapper.YamlObjectMapper] methods, handling
/// YAML parsing and generation. It maintains the hierarchy: ObjectMapper →
/// AbstractXmlObjectMapper → AbstractYamlObjectMapper, allowing clean separation
/// of XML and YAML concerns.
///
/// ### Design Hierarchy
/// ```
/// ObjectMapper (JSON)
///   ↓
/// AbstractXmlObjectMapper (XML)
///   ↓
/// AbstractYamlObjectMapper (YAML)
///   ↓
/// JetsonObjectMapper (Concrete implementation)
/// ```
///
/// ### Responsibilities
/// This class handles:
/// - YAML content parsing via [yaml_mapper.YamlParser]
/// - Tree-based YAML navigation via [yaml_mapper.YamlNode]
/// - Format conversions between YAML strings and maps
/// - Support for YAML-specific features (anchors, aliases)
/// - Integration with Jetson's naming strategies and converters
///
/// ### Extension
/// Subclasses should override:
/// - [writeValueAsYaml] - Customize YAML serialization
/// - [readYamlValue] - Customize YAML deserialization
/// - Other YAML-specific methods as needed
///
/// ### Example
/// ```dart
/// class MyYamlMapper extends AbstractYamlObjectMapper {
///   @override
///   String writeValueAsYaml(Object? value) {
///     // Custom YAML serialization
///   }
///   
///   @override
///   T readYamlValue<T>(String yaml, Class<T> type) {
///     // Custom YAML deserialization
///   }
/// }
/// ```
///
/// ### Related Classes
/// - [AbstractXmlObjectMapper] - XML serialization layer
/// - [yaml_mapper.YamlObjectMapper] - Interface definition
/// - [ObjectMapper] - Base contract for all mappers
/// {@endtemplate}
abstract class AbstractYamlObjectMapper extends AbstractXmlObjectMapper implements yaml_mapper.YamlObjectMapper {
  /// {@macro abstract_yaml_object_mapper}
  AbstractYamlObjectMapper() : super();

  @override
  String writeValueAsYaml(Object? value) {
    throw UnimplementedError(
      'writeValueAsYaml must be implemented by subclass.'
    );
  }

  @override
  Map<String, dynamic> writeValueAsYamlMap(Object? value) {
    throw UnimplementedError(
      'writeValueAsYamlMap must be implemented by subclass.'
    );
  }

  @override
  T readYamlValue<T>(String yaml, Class<T> type) {
    throw UnimplementedError(
      'readYamlValue must be implemented by subclass.'
    );
  }

  @override
  T readYamlValueFromMap<T>(Map<String, dynamic> map, Class<T> type) {
    throw UnimplementedError(
      'readYamlValueFromMap must be implemented by subclass.'
    );
  }

  @override
  yaml_mapper.YamlNode readYamlContentTree(String content) {
    throw UnimplementedError(
      'readYamlContentTree must be implemented by subclass.'
    );
  }

  @override
  yaml_mapper.YamlNode readYamlTree(yaml_mapper.YamlParser parser) {
    throw UnimplementedError(
      'readYamlTree must be implemented by subclass.'
    );
  }
}
