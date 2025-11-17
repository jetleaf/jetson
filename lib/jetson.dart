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

/// Jetson JSON Mapping Library
///
/// This library provides a comprehensive set of tools for **JSON serialization
/// and deserialization** in Dart, inspired by the flexibility and configurability
/// of Jackson in Java. It includes:
///
/// - **Annotations**: Custom annotations for controlling field serialization and deserialization.
/// - **Object Mappers**: `JetsonObjectMapper` and builder classes for fluent configuration.
/// - **Serializers / Deserializers**: Standard and custom handlers for Dart types.
/// - **JSON Nodes**: Tree-like representation of JSON content for flexible traversal.
/// - **Converter Adapters**: Bidirectional adapters for converting Dart types to/from JSON.
/// - **Naming Strategies**: Field naming conventions such as snake_case, camelCase, etc.
/// - **Exceptions**: Custom exceptions for parsing and serialization errors.
/// - **String-based Generators and Parsers**: Default implementations for JSON I/O.
///
/// Usage:
/// ```dart
/// import 'package:jetson/jetson.dart';
///
/// final mapper = ObjectMapper();
/// final json = mapper.writeValueAsString({'name': 'Alice'});
/// final map = mapper.readValue<Map<String, dynamic>>(json, Class<Map<String, dynamic>>());
/// print(map['name']); // Alice
/// ```
///
/// This library is fully extensible and configurable via custom serializers,
/// deserializers, naming strategies, parser factories, and feature flags.
library jetson;

export 'src/adapters/date_time_json_converter_adapter.dart';
export 'src/adapters/duration_json_converter_adapter.dart';
export 'src/adapters/local_date_json_converter_adapter.dart';
export 'src/adapters/local_date_time_json_converter_adapter.dart';
export 'src/adapters/uri_json_converter_adapter.dart';
export 'src/adapters/url_json_converter_adapter.dart';
export 'src/adapters/zoned_date_time_json_converter_adapter.dart';

export 'src/object_mapper/jetson_object_mapper.dart';
export 'src/object_mapper/jetson_object_mapper_builder.dart';

export 'src/context/default_deserialization_context.dart';
export 'src/context/default_serializer_provider.dart';

export 'src/serializers/standard_deserializers.dart';
export 'src/serializers/standard_serializers.dart';
export 'src/serializers/dart_serializer.dart';
export 'src/serializers/dart_deserializer.dart';

export 'src/json/json_node.dart';
export 'src/json/json_validator.dart';

export 'src/annotations.dart';
export 'src/base.dart';
export 'src/exceptions.dart';
export 'src/naming_strategies.dart';

export 'src/json/string_json_generator.dart';
export 'src/json/string_json_parser.dart';

export 'src/xml/abstract_xml_object_mapper.dart';
export 'src/xml/xml_node.dart';
export 'src/xml/xml_object_mapper.dart';

export 'src/yaml/abstract_yaml_object_mapper.dart';
export 'src/yaml/yaml_object_mapper.dart';