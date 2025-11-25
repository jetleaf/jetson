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

/// 🌐 **JetLeaf Jetson Object Mapping & Serialization Library**
///
/// Jetson provides a comprehensive framework for serializing and
/// deserializing objects across multiple formats, including:
/// - JSON  
/// - XML  
/// - YAML
///
/// It supports advanced features such as:
/// - annotation-driven object mapping  
/// - pluggable adapters and serializers  
/// - naming strategies  
/// - context-aware serialization/deserialization  
/// - validation of structured data
///
/// This library is intended for robust data binding and format conversions
/// in JetLeaf applications.
///
///
/// ## 🔑 Core Concepts
///
/// ### 🧱 Base Infrastructure
/// - `Generator`, `Node`, `ObjectMapper`, `ObjectMapperType`, `Parser`
///   — foundational abstractions for all object mapping operations
///
///
/// ### 🔄 Serialization & Deserialization
/// - `BaseSerializer`, `ObjectSerializer`, `ObjectDeserializer`
/// - `SerializationContext` / `DeserializationContext`
/// - `SerializationFeature` / `DeserializationFeature`
/// - `ObjectSerializable` — marker interface for serializable objects
///
///
/// ### ⏱ Common Adapters & Helpers
/// - `StandardSerializers`, `StandardDeserializers` — default implementations  
/// - `TimeSerializationAdapters` — adapters for handling date/time types
///
///
/// ### 🔧 Jetson Core Mappers
/// - `JetsonObjectMapper` — main object mapper implementation  
/// - `AbstractJsonObjectMapper`, `AbstractXmlObjectMapper`, `AbstractYamlObjectMapper`  
/// - `AbstractAwareObjectMapper` — advanced context-aware mapping
///
///
/// ### 📄 JSON Support
/// - Node types: `JsonNode`, `JsonArrayNode`, `JsonMapNode`, `JsonTextNode`, `JsonBooleanNode`, `JsonNumberNode`, `JsonNullNode`  
/// - Generators: `JsonGenerator`, `StringJsonGenerator`  
/// - Parsers: `JsonParser`, `StringJsonParser`  
/// - Adapters: `JsonAdapter`, `DartJsonSerializationAdapter`, `List/Map/SetJsonSerializationAdapter`  
/// - `JsonObjectMapper`, `JsonToken`, `JsonDeserializationContext`, `JsonSerializationContext`  
/// - `JsonValidator` — validates JSON content
///
///
/// ### 📄 XML Support
/// - Node types: `XmlNode`, `XmlElementNode`, `XmlTextNode`  
/// - Generators: `XmlGenerator`, `StringXmlGenerator`  
/// - Parsers: `XmlParser`, `StringXmlParser`  
/// - Adapters: `XmlAdapter`, `DartXmlSerializationAdapter`, `List/Map/SetXmlSerializationAdapter`  
/// - `XmlObjectMapper`, `XmlToken`, `XmlDeserializationContext`, `XmlSerializationContext`
///
///
/// ### 📄 YAML Support
/// - Node types: `YamlNode`, `YamlMapNode`, `YamlScalarNode`, `YamlSequenceNode`, `YamlNodeType`  
/// - Generators: `YamlGenerator`, `StringYamlGenerator`  
/// - Parsers: `YamlParser`, `StringYamlParser`  
/// - Adapters: `YamlAdapter`, `DartYamlSerializationAdapter`, `List/Map/SetYamlSerializationAdapter`  
/// - `YamlObjectMapper`, `YamlToken`, `YamlDeserializationContext`, `YamlSerializationContext`
///
///
/// ### 🏷 Annotations & Naming Strategies
/// - `annotations.dart` — declarative mapping and serialization annotations  
/// - `naming_strategy.dart` / `naming_strategies.dart` — control field name transformations
///
///
/// ### ⚠ Exception Handling
/// - `exceptions.dart` — framework-level exception types
///
///
/// ### 🛠 Utilities
/// - `jetson_utils.dart` — helper functions for common mapping operations
///
///
/// ## 🎯 Intended Usage
///
/// Import this library for advanced object mapping and format conversions:
/// ```dart
/// import 'package:jetson/jetson.dart';
///
/// final mapper = JetsonObjectMapper();
/// final json = mapper.serializeToJson(myObject);
/// final obj = mapper.deserializeFromJson<MyClass>(json);
/// ```
///
/// Supports annotation-driven mapping, custom adapters, context-aware serialization,
/// and validation for multiple formats (JSON, XML, YAML).
///
///
/// © 2025 Hapnium & JetLeaf Contributors
library;

export 'src/base/generator.dart';
export 'src/base/node.dart';
export 'src/base/object_mapper.dart';
export 'src/base/object_mapper_type.dart';
export 'src/base/parser.dart';

export 'src/common/time_serialization_adapters.dart';
export 'src/common/standard_deserializers.dart';
export 'src/common/standard_serializers.dart';

export 'src/jetson/abstract_json_object_mapper.dart';
export 'src/jetson/abstract_xml_object_mapper.dart';
export 'src/jetson/abstract_yaml_object_mapper.dart';
export 'src/jetson/jetson_object_mapper.dart';
export 'src/jetson/abstract_aware_object_mapper.dart';

export 'src/json/adapter/json_adapter.dart';
export 'src/json/adapter/dart_json_serialization_adapter.dart';
export 'src/json/adapter/list_json_serialization_adapter.dart';
export 'src/json/adapter/map_json_serialization_adapter.dart';
export 'src/json/adapter/set_json_serialization_adapter.dart';

export 'src/json/context/json_deserialization_context.dart';
export 'src/json/context/json_serialization_context.dart';

export 'src/json/generator/string_json_generator.dart';
export 'src/json/generator/json_generator.dart';

export 'src/json/node/json_node.dart';
export 'src/json/node/json_array_node.dart';
export 'src/json/node/json_boolean_node.dart';
export 'src/json/node/json_map_node.dart';
export 'src/json/node/json_null_node.dart';
export 'src/json/node/json_number_node.dart';
export 'src/json/node/json_text_node.dart';

export 'src/json/parser/string_json_parser.dart';
export 'src/json/parser/json_parser.dart';

export 'src/json/json_validator.dart';
export 'src/json/json_object_mapper.dart';
export 'src/json/json_token.dart';

export 'src/naming_strategy/naming_strategy.dart';
export 'src/naming_strategy/naming_strategies.dart';

export 'src/serialization/base_serializer.dart';
export 'src/serialization/deserialization_context.dart';
export 'src/serialization/deserialization_feature.dart';
export 'src/serialization/object_deserializer.dart';
export 'src/serialization/object_serializable.dart';
export 'src/serialization/object_serializer.dart';
export 'src/serialization/serialization_context.dart';
export 'src/serialization/serialization_feature.dart';

// XML

export 'src/xml/adapter/xml_adapter.dart';
export 'src/xml/adapter/dart_xml_serialization_adapter.dart';
export 'src/xml/adapter/list_xml_serialization_adapter.dart';
export 'src/xml/adapter/map_xml_serialization_adapter.dart';
export 'src/xml/adapter/set_xml_serialization_adapter.dart';

export 'src/xml/context/xml_deserialization_context.dart';
export 'src/xml/context/xml_serialization_context.dart';

export 'src/xml/generator/string_xml_generator.dart';
export 'src/xml/generator/xml_generator.dart';

export 'src/xml/node/xml_node.dart';
export 'src/xml/node/xml_element_node.dart';
export 'src/xml/node/xml_text_node.dart';

export 'src/xml/parser/string_xml_parser.dart';
export 'src/xml/parser/xml_parser.dart';

export 'src/xml/xml_object_mapper.dart';
export 'src/xml/xml_token.dart';

// YAML

export 'src/yaml/adapter/yaml_adapter.dart';
export 'src/yaml/adapter/dart_yaml_serialization_adapter.dart';
export 'src/yaml/adapter/list_yaml_serialization_adapter.dart';
export 'src/yaml/adapter/map_yaml_serialization_adapter.dart';
export 'src/yaml/adapter/set_yaml_serialization_adapter.dart';

export 'src/yaml/context/yaml_deserialization_context.dart';
export 'src/yaml/context/yaml_serialization_context.dart';

export 'src/yaml/generator/string_yaml_generator.dart';
export 'src/yaml/generator/yaml_generator.dart';

export 'src/yaml/node/yaml_node.dart';
export 'src/yaml/node/yaml_map_node.dart';
export 'src/yaml/node/yaml_node_type.dart';
export 'src/yaml/node/yaml_scalar_node.dart';
export 'src/yaml/node/yaml_sequence_node.dart';

export 'src/yaml/parser/string_yaml_parser.dart';
export 'src/yaml/parser/yaml_parser.dart';

export 'src/yaml/yaml_object_mapper.dart';
export 'src/yaml/yaml_token.dart';

export 'src/annotations.dart';
export 'src/exceptions.dart';
export 'src/jetson_utils.dart';