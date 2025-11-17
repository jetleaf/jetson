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
import '../xml/xml_object_mapper.dart';

/// {@template yaml_object_mapper}
/// Extends the [ObjectMapper] interface to provide specialized support for
/// **YAML serialization and deserialization**.
///
/// The [YamlObjectMapper] builds upon the base [ObjectMapper] contract by adding
/// YAML-specific methods for reading and writing Dart objects in YAML format.
/// It maintains full compatibility with the standard JSON mapper interface
/// while providing YAML-focused operations.
///
/// ### Core Methods
/// - **[readYamlValue]** - Deserializes YAML string to Dart object
/// - **[readYamlValueFromMap]** - Deserializes YAML map to Dart object
/// - **[readYamlTree]** - Parses YAML string to [YamlNode] tree
/// - **[writeValueAsYaml]** - Serializes Dart object to YAML string
/// - **[writeValueAsYamlMap]** - Serializes Dart object to YAML map
///
/// ### Design Notes
/// - Inherits all JSON serialization methods from [ObjectMapper]
/// - YAML-specific methods follow the same naming patterns as JSON counterparts
/// - Supports both tree-based (DOM) and streaming YAML processing
/// - Integrates with Jetson's naming strategies and converters
/// - Supports YAML-specific features like anchors, aliases, and multi-line strings
///
/// ### Example
/// ```dart
/// final mapper = YamlObjectMapper();
///
/// // Serialization
/// final user = User(id: 1, name: 'Alice', email: 'alice@example.com');
/// final yaml = mapper.writeValueAsYaml(user);
/// // Output:
/// // user:
/// //   id: 1
/// //   name: Alice
/// //   email: alice@example.com
///
/// // Deserialization
/// final restored = mapper.readYamlValue<User>(yaml, Class<User>());
/// ```
///
/// ### Related Interfaces
/// - [ObjectMapper] - Base serialization/deserialization contract
/// - [XmlObjectMapper] - XML-specific operations
/// - [YamlNode] - YAML DOM tree representation
/// {@endtemplate}
abstract interface class YamlObjectMapper implements ObjectMapper {
  // ─────────────────────────────────────────────────────────────
  // YAML Serialization
  // ─────────────────────────────────────────────────────────────

  /// Serializes a Dart object into a YAML string.
  ///
  /// Converts the given [value] into a YAML-encoded string using the current
  /// [NamingStrategy], annotations, and registered serializers.
  ///
  /// ### Example
  /// ```dart
  /// final yaml = mapper.writeValueAsYaml(user);
  /// print(yaml);
  /// // user:
  /// //   id: 1
  /// //   name: Alice
  /// ```
  ///
  /// ### Notes
  /// - Respects YAML-specific naming conventions
  /// - Handles nested objects, collections, and custom types
  /// - Supports YAML features like anchors and aliases for deduplication
  /// - Produces human-readable, indented output by default
  String writeValueAsYaml(Object? value);

  /// Serializes a Dart object into a YAML `Map<String, dynamic>` representation.
  ///
  /// This method traverses all serializable fields of [value] and produces
  /// a nested map structure compatible with YAML generation.
  ///
  /// ### Example
  /// ```dart
  /// final map = mapper.writeValueAsYamlMap(user);
  /// print(map['user']['id']); // 1
  /// ```
  Map<String, dynamic> writeValueAsYamlMap(Object? value);

  // ─────────────────────────────────────────────────────────────
  // YAML Deserialization
  // ─────────────────────────────────────────────────────────────

  /// Deserializes a YAML string into an object of type [T].
  ///
  /// The YAML is parsed into an intermediate [YamlNode] tree, which is then
  /// mapped to a Dart object using reflection and configured converters.
  ///
  /// ### Example
  /// ```dart
  /// final user = mapper.readYamlValue<User>(
  ///   'user:\n  id: 1\n  name: Alice',
  ///   Class<User>()
  /// );
  /// ```
  ///
  /// ### Error Handling
  /// Throws an exception if:
  /// - The YAML is malformed
  /// - No deserializer found for type [T]
  /// - Required fields are missing
  T readYamlValue<T>(String yaml, Class<T> type);

  /// Deserializes a YAML-compatible map into an instance of type [T].
  ///
  /// This bypasses YAML parsing and directly performs field mapping from
  /// a nested [Map<String, dynamic>] to a Dart object.
  ///
  /// ### Example
  /// ```dart
  /// final user = mapper.readYamlValueFromMap<User>({
  ///   'user': {
  ///     'id': 1,
  ///     'name': 'Alice'
  ///   }
  /// }, Class<User>());
  /// ```
  T readYamlValueFromMap<T>(Map<String, dynamic> map, Class<T> type);

  // ─────────────────────────────────────────────────────────────
  // YAML Tree Operations
  // ─────────────────────────────────────────────────────────────

  /// Parses the given YAML [content] string into a [YamlNode] tree.
  ///
  /// This allows you to traverse or inspect YAML data without binding it
  /// to a specific object type.
  ///
  /// ### Example
  /// ```dart
  /// final tree = mapper.readYamlContentTree('root:\n  child: value');
  /// print(tree.get('root').get('child').getText()); // "value"
  /// ```
  ///
  /// ### Notes
  /// - Returns the root [YamlNode] of the parsed document
  /// - Supports navigation via [YamlNode] methods
  /// - Preserves mapping keys and scalar values
  /// - Handles YAML-specific features like anchors and aliases
  YamlNode readYamlContentTree(String content);

  /// Reads and parses YAML content from the given [YamlParser] into a [YamlNode] tree.
  ///
  /// Useful when working with streaming or preconfigured YAML parsers.
  /// The returned tree can be navigated like a DOM.
  ///
  /// ### Example
  /// ```dart
  /// final parser = mapper.createYamlParser(yamlString);
  /// final tree = mapper.readYamlTree(parser);
  /// ```
  ///
  /// ### See also
  /// - [YamlParser]
  /// - [readYamlContentTree]
  YamlNode readYamlTree(YamlParser parser);
}

/// {@template yaml_node}
/// Represents a **node in a YAML document tree** (DOM-like structure).
///
/// A [YamlNode] provides both **hierarchical navigation** and **direct access**
/// to YAML data, supporting mappings (objects), sequences (arrays), and scalars
/// (values).
///
/// ### Node Types
/// - **Mapping nodes** - Represent YAML key-value mappings (like maps)
/// - **Sequence nodes** - Represent YAML arrays/lists
/// - **Scalar nodes** - Represent simple values (strings, numbers, booleans)
/// - **Alias nodes** - Represent references to anchored values
///
/// ### Navigation
/// ```dart
/// final root = tree.get('users');
/// final firstUser = root.get('[0]');
/// final name = firstUser.get('name').getText();
/// ```
///
/// ### Example
/// ```dart
/// final yaml = '''
/// users:
///   - name: Alice
///     age: 30
///   - name: Bob
///     age: 25
/// ''';
/// final tree = parser.readTree(yaml);
/// final users = tree.get('users');
/// final alice = users.get('[0]');
///
/// print(alice.get('name').getText()); // "Alice"
/// print(alice.get('age').getText()); // "30"
/// ```
/// {@endtemplate}
abstract class YamlNode {
  /// Returns the **type** of this YAML node.
  ///
  /// Can be 'mapping', 'sequence', or 'scalar'.
  String? getNodeType();

  /// Returns the **scalar value** of this node.
  ///
  /// For SCALAR nodes, returns the parsed value.
  /// For MAPPING or SEQUENCE nodes, may return null.
  String? getText();

  /// Returns the **child node** with the given [key].
  ///
  /// For mappings, [key] is the map key.
  /// For sequences, [key] should be an index like '[0]', '[1]', etc.
  /// Returns `null` if no matching child exists.
  ///
  /// ### Example
  /// ```dart
  /// final name = mapping.get('name');
  /// final first = sequence.get('[0]');
  /// ```
  YamlNode? get(String key);

  /// Returns **all child nodes** with the given [key].
  ///
  /// For sequences, returns all elements.
  /// For mappings, may return values for all matching keys (rarely used).
  /// Returns an empty list if no children match.
  List<YamlNode> getAll(String key);

  /// Returns the **list of all keys** in a mapping node.
  ///
  /// For non-mapping nodes, returns an empty list.
  List<String> getKeys();

  /// Returns the **list of all child nodes** in a sequence.
  ///
  /// For non-sequence nodes, returns an empty list.
  List<YamlNode> getElements();

  /// Converts this node to a **Dart object** of type [T].
  ///
  /// This is a convenience method for converting YAML data back
  /// to strongly-typed Dart objects.
  ///
  /// ### Example
  /// ```dart
  /// final user = tree.toObject<User>();
  /// ```
  Object? toObject<T>();
}

/// {@template yaml_parser}
/// A **streaming YAML reader** that sequentially exposes parsed YAML tokens.
///
/// The [YamlParser] provides low-level, pull-based access to YAML input,
/// allowing deserializers to process data incrementally without loading
/// entire documents into memory.
///
/// ### Overview
/// - Reads from strings, byte streams, or character sources
/// - Emits tokens ([YamlToken]) as it parses
/// - Allows skipping nested structures efficiently
/// - Supports anchors and aliases for reference resolution
///
/// ### See also
/// - [YamlToken]
/// - [YamlObjectMapper]
/// - [YamlNode]
/// {@endtemplate}
abstract interface class YamlParser {
  /// Advances the parser to the **next YAML token**.
  ///
  /// Returns `true` if another token exists, or `false` when end of input
  /// is reached.
  bool nextToken();

  /// Returns the **current token type** (mapping, sequence, scalar, etc.).
  ///
  /// ### Example
  /// ```dart
  /// if (parser.getCurrentToken() == YamlToken.KEY) {
  ///   print('Key: ${parser.getScalarValue()}');
  /// }
  /// ```
  YamlToken? getCurrentToken();

  /// Returns the **scalar value** of the current token.
  ///
  /// For SCALAR tokens, returns the string value.
  /// For other tokens, may return null.
  String? getScalarValue();

  /// Returns the **anchor name** if this token is anchored.
  ///
  /// For tokens with anchors (e.g., `&anchor value`), returns the anchor name.
  /// Returns `null` if no anchor is present.
  String? getAnchor();

  /// Returns the **alias reference** if this token is an alias.
  ///
  /// For ALIAS tokens, returns the referenced anchor name.
  String? getAlias();

  /// Skips the **current structure** (mapping or sequence).
  void skipStructure();
}

/// Enumerates all **token types** that a [YamlParser] can encounter during
/// YAML parsing.
///
/// ### Example
/// ```dart
/// if (parser.getCurrentToken() == YamlToken.SCALAR) {
///   print('Value: ${parser.getScalarValue()}');
/// }
/// ```
enum YamlToken {
  /// Start of a YAML mapping (dictionary/object).
  MAPPING_START,

  /// End of a YAML mapping.
  MAPPING_END,

  /// Key in a mapping.
  KEY,

  /// Value in a mapping or element.
  VALUE,

  /// Start of a YAML sequence (array/list).
  SEQUENCE_START,

  /// End of a YAML sequence.
  SEQUENCE_END,

  /// A scalar (simple) value.
  SCALAR,

  /// An alias (reference to an anchored value).
  ALIAS,

  /// End of document.
  END_DOCUMENT,
}
