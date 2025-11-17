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
import 'xml_node.dart';
import 'xml_object_mapper.dart' as xml_mapper;

/// {@template abstract_xml_object_mapper}
/// Abstract base implementation of [xml_mapper.XmlObjectMapper] providing core XML
/// serialization and deserialization functionality.
///
/// This class implements all [xml_mapper.XmlObjectMapper] methods using XML parsing
/// and serialization. Subclasses provide the actual implementation details for
/// parsing XML content and building objects from XML nodes.
///
/// ### Design
/// - Handles XML serialization and deserialization contract
/// - Delegates format-specific XML processing to subclasses
/// - Reuses [ObjectMapper] methods for JSON operations where applicable
/// - Provides XML-specific entry points without coupling to implementation
///
/// ### Responsibilities
/// This class handles:
/// - XML content parsing and tree traversal
/// - Tree-based XML navigation via [XmlNode]
/// - Format conversions between XML strings and maps
/// - Integration with Jetson's naming strategies and converters
///
/// ### Extension
/// Subclasses should override:
/// - [writeValueAsXml] - Custom XML serialization
/// - [readXmlValue] - Custom XML deserialization
/// - [readXmlTree] - XML tree parsing implementation
/// - Other methods as needed for custom XML processing
///
/// ### Example
/// ```dart
/// class MyXmlMapper extends AbstractXmlObjectMapper {
///   @override
///   String writeValueAsXml(Object? value) {
///     // Custom XML serialization
///   }
/// }
/// ```
///
/// ### Related Classes
/// - [AbstractYamlObjectMapper] - YAML extension
/// - [xml_mapper.XmlObjectMapper] - Interface definition
/// - [ObjectMapper] - Base mapping contract
/// {@endtemplate}
abstract class AbstractXmlObjectMapper implements xml_mapper.XmlObjectMapper {
  /// {@macro abstract_xml_object_mapper}
  AbstractXmlObjectMapper();

  @override
  String writeValueAsXml(Object? value) {
    throw UnimplementedError(
      'writeValueAsXml must be implemented by subclass.'
    );
  }

  @override
  Map<String, dynamic> writeValueAsXmlMap(Object? value) {
    throw UnimplementedError(
      'writeValueAsXmlMap must be implemented by subclass.'
    );
  }

  @override
  T readXmlValue<T>(String xml, Class<T> type) {
    throw UnimplementedError(
      'readXmlValue must be implemented by subclass.'
    );
  }

  @override
  T readXmlValueFromMap<T>(Map<String, dynamic> map, Class<T> type) {
    throw UnimplementedError(
      'readXmlValueFromMap must be implemented by subclass.'
    );
  }

  @override
  XmlNode readXmlContentTree(String content) {
    throw UnimplementedError(
      'readXmlContentTree must be implemented by subclass.'
    );
  }

  @override
  XmlNode readXmlTree(xml_mapper.XmlParser parser) {
    throw UnimplementedError(
      'readXmlTree must be implemented by subclass.'
    );
  }
}
