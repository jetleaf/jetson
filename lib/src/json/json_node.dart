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

/// {@template jetleaf_json_node}
/// Base class for all **JSON nodes** in the Dart model.  
///
/// Each implementation represents a JSON value, such as an object, array,
/// string, number, boolean, or null. This class provides type-checking
/// helpers and a method to convert the node back to a Dart object.
///
/// ### Usage Example
/// ```dart
/// final node = JsonObjectNode({
///   'name': JsonTextNode('Alice'),
///   'age': JsonNumberNode(30),
/// });
///
/// if (node.isObject()) {
///   print('This is a JSON object.');
/// }
///
/// final obj = node.toObject();
/// print(obj); // {'name': 'Alice', 'age': 30}
/// ```
///
/// ### Behavior Overview
/// | Node Type | Dart Representation | Description |
/// |-----------|------------------|-------------|
/// | Object | `Map<String, Object>` | JSON objects |
/// | Array | `List<Object>` | JSON arrays |
/// | Text | `String` | JSON strings |
/// | Number | `num` | JSON numbers |
/// | Boolean | `bool` | JSON boolean |
/// | Null | `null` | JSON null |
///
/// ### Design Notes
/// - Provides convenient type-checking methods (`isObject()`, `isArray()`, etc.).  
/// - Supports conversion back to Dart objects via `toObject()`.  
/// - Serves as the base for all concrete JSON node implementations.  
///
/// ### See Also
/// - [JsonObjectNode]
/// - [JsonArrayNode]
/// - [JsonTextNode]
/// - [JsonNumberNode]
/// - [JsonBooleanNode]
/// - [JsonNullNode]
/// {@endtemplate}
abstract interface class JsonNode {
  /// {@macro jetleaf_json_node}
  const JsonNode();
  
  /// Returns `true` if this node represents a JSON object (`{...}`).
  ///
  /// JSON objects are represented as Dart [Map<String, Object>] when converted
  /// via [toObject]. Use this method to safely check the node type before
  /// casting or iterating its fields.
  ///
  /// ### Example
  /// ```dart
  /// if (node.isObject()) {
  ///   final map = node.toObject() as Map<String, Object>;
  ///   print(map.keys);
  /// }
  /// ```
  bool isObject();

  /// Returns `true` if this node represents a JSON array (`[...]`).
  ///
  /// JSON arrays are represented as Dart [List<Object>] when converted
  /// via [toObject]. This is useful for iterating elements or validating
  /// the type before performing array operations.
  ///
  /// ### Example
  /// ```dart
  /// if (node.isArray()) {
  ///   final list = node.toObject() as List<Object>;
  ///   print(list.length);
  /// }
  /// ```
  bool isArray();

  /// Returns `true` if this node represents a JSON string.
  ///
  /// JSON strings are represented as Dart [String] when converted via
  /// [toObject]. This method allows safe type-checking before performing
  /// string operations like concatenation or formatting.
  ///
  /// ### Example
  /// ```dart
  /// if (node.isTextual()) {
  ///   final text = node.toObject() as String;
  ///   print(text.toUpperCase());
  /// }
  /// ```
  bool isTextual();

  /// Returns `true` if this node represents a JSON number.
  ///
  /// JSON numbers can be either [int] or [double] in Dart. This method
  /// ensures that the node can safely be cast to [num] before arithmetic
  /// operations.
  ///
  /// ### Example
  /// ```dart
  /// if (node.isNumber()) {
  ///   final number = node.toObject() as num;
  ///   print(number + 10);
  /// }
  /// ```
  bool isNumber();

  /// Returns `true` if this node represents a JSON boolean (`true` or `false`).
  ///
  /// JSON booleans are represented as Dart [bool]. Use this method to
  /// safely check the node type before performing logical operations.
  ///
  /// ### Example
  /// ```dart
  /// if (node.isBoolean()) {
  ///   final flag = node.toObject() as bool;
  ///   print(flag ? 'Yes' : 'No');
  /// }
  /// ```
  bool isBoolean();

  /// Returns `true` if this node represents a JSON `null`.
  ///
  /// JSON null is represented as Dart `null`. This method allows you to
  /// detect missing or empty values safely.
  ///
  /// ### Example
  /// ```dart
  /// if (node.isNull()) {
  ///   print('This node is null');
  /// }
  /// ```
  bool isNull();

  /// Converts the JSON node into a **native Dart object**.
  ///
  /// The returned object matches the JSON type:
  /// - JSON object → `Map<String, Object>`
  /// - JSON array → `List<Object>`
  /// - JSON string → `String`
  /// - JSON number → `num`
  /// - JSON boolean → `bool`
  /// - JSON null → `null`
  ///
  /// Use this method to work with standard Dart collections instead of
  /// custom node types.
  ///
  /// ### Example
  /// ```dart
  /// final map = node.toObject() as Map<String, Object>;
  /// print(map['name']); // prints the value of the 'name' field
  /// ```
  Object toObject();
}

/// {@template jetleaf_json_object_node}
/// Represents a **JSON object node** (`{...}`) in the Dart JSON model.
///
/// Each field in the object is stored as a key-value pair, where the key
/// is a `String` and the value is another [JsonNode]. This node allows
/// building hierarchical JSON structures programmatically.
///
/// ### Usage Example
/// ```dart
/// final objNode = JsonObjectNode();
/// objNode.set('name', JsonTextNode('Alice'));
/// objNode.set('age', JsonNumberNode(30));
///
/// final nameNode = objNode.get('name');
/// print(nameNode?.toObject()); // 'Alice'
///
/// final map = objNode.toObject();
/// print(map); // {'name': 'Alice', 'age': 30}
/// ```
///
/// ### Behavior Overview
/// | Dart JSON Object | Internal Representation | Description |
/// |-----------------|------------------------|-------------|
/// | `{}` | `_fields` empty map | Empty JSON object |
/// | `{"a": 1}` | `_fields['a'] = JsonNumberNode(1)` | Simple field |
/// | `{"nested": {"x": true}}` | `_fields['nested'] = JsonObjectNode(...)` | Nested object |
///
/// ### Design Notes
/// - Maintains fields in a `Map<String, JsonNode>` for fast key lookup.
/// - Supports programmatic addition and retrieval of fields via [set] and [get].
/// - [toObject] converts the node and all nested nodes to native Dart objects recursively.
/// - Type-checking is consistent with [JsonNode] methods.
/// {@endtemplate}
class JsonObjectNode extends JsonNode {
  /// {@macro jetleaf_json_object_node}
  JsonObjectNode();

  /// Internal storage for the object’s fields.
  final Map<String, JsonNode> _fields = {};

  /// Sets or replaces a field in the JSON object.
  ///
  /// If a field with the given [key] already exists, its value is replaced
  /// with [value]. Otherwise, a new field is added.
  ///
  /// ### Example
  /// ```dart
  /// final obj = JsonObjectNode();
  /// obj.set('name', JsonTextNode('Alice'));
  /// obj.set('age', JsonNumberNode(30));
  /// ```
  void set(String key, JsonNode value) {
    _fields[key] = value;
  }

  /// Retrieves the [JsonNode] associated with the given [key].
  ///
  /// Returns `null` if the key does not exist in this object.
  ///
  /// ### Example
  /// ```dart
  /// final node = obj.get('name');
  /// if (node != null && node.isTextual()) {
  ///   print(node.toObject()); // 'Alice'
  /// }
  /// ```
  JsonNode? get(String key) => _fields[key];

  /// Returns an unmodifiable view of all fields in this JSON object.
  ///
  /// The keys are [String] and the values are [JsonNode]. Modifying the
  /// returned map will affect the internal state of this object.
  ///
  /// ### Example
  /// ```dart
  /// final allFields = obj.fields;
  /// print(allFields.keys); // ['name', 'age']
  /// ```
  Map<String, JsonNode> get fields => _fields;

  @override
  bool isObject() => true;

  @override
  bool isArray() => false;

  @override
  bool isTextual() => false;

  @override
  bool isNumber() => false;

  @override
  bool isBoolean() => false;

  @override
  bool isNull() => false;

  @override
  Map<String, dynamic> toObject() {
    final map = <String, dynamic>{};
    _fields.forEach((k, v) => map[k] = v.toObject());
    return map;
  }
}

/// {@template jetleaf_json_array_node}
/// Represents a **JSON array node** (`[...]`) in the Dart JSON model.
///
/// Each element in the array is a [JsonNode], allowing hierarchical
/// JSON structures to be constructed programmatically.
///
/// ### Usage Example
/// ```dart
/// final arrayNode = JsonArrayNode();
/// arrayNode.add(JsonTextNode('Alice'));
/// arrayNode.add(JsonNumberNode(30));
///
/// final first = arrayNode.elements.first;
/// print(first.toObject()); // 'Alice'
///
/// final list = arrayNode.toObject();
/// print(list); // ['Alice', 30]
/// ```
///
/// ### Behavior Overview
/// | Dart JSON Array | Internal Representation | Description |
/// |----------------|------------------------|-------------|
/// | `[]` | `_elements` empty list | Empty array |
/// | `[1, 2, 3]` | `_elements = [JsonNumberNode(1), ...]` | Simple numeric array |
/// | `[{"a":1}, "text"]` | Nested object and string nodes | Mixed types supported |
///
/// ### Design Notes
/// - Maintains elements in a `List<JsonNode>` to preserve order.
/// - Supports programmatic addition via [add].
/// - [toObject] converts the node and all nested nodes to native Dart objects recursively.
/// - Type-checking is consistent with [JsonNode] methods.
/// {@endtemplate}
class JsonArrayNode extends JsonNode {
  /// {@macro jetleaf_json_array_node}
  JsonArrayNode();

  /// Internal storage for the array’s elements.
  final List<JsonNode> _elements = [];

  /// Adds a [JsonNode] to the end of this JSON array.
  ///
  /// Preserves the order of insertion. The array can contain mixed types.
  ///
  /// ### Example
  /// ```dart
  /// final array = JsonArrayNode();
  /// array.add(JsonTextNode('Alice'));
  /// array.add(JsonNumberNode(30));
  /// ```
  void add(JsonNode value) => _elements.add(value);

  /// Returns a read-only view of the elements in this array.
  ///
  /// Each element is a [JsonNode], allowing traversal or inspection.
  ///
  /// ### Example
  /// ```dart
  /// final first = array.elements.first;
  /// print(first.toObject()); // 'Alice'
  /// ```
  List<JsonNode> get elements => _elements;

  @override
  bool isObject() => false;

  @override
  bool isArray() => true;

  @override
  bool isTextual() => false;

  @override
  bool isNumber() => false;

  @override
  bool isBoolean() => false;

  @override
  bool isNull() => false;

  @override
  List<dynamic> toObject() => _elements.map((e) => e.toObject()).toList();
}

/// {@template jetleaf_json_text_node}
/// Represents a **JSON string node** in the Dart JSON model.
///
/// This node wraps a [String] value and provides type-checking
/// consistent with [JsonNode].
///
/// ### Usage Example
/// ```dart
/// final textNode = JsonTextNode('Hello, world!');
///
/// if (textNode.isTextual()) {
///   print(textNode.toObject()); // 'Hello, world!'
/// }
/// ```
///
/// ### Behavior Overview
/// | Dart JSON Value | Internal Representation | Description |
/// |-----------------|------------------------|-------------|
/// | `"text"` | `value = 'text'` | Simple JSON string |
/// | `""` | `value = ''` | Empty string |
///
/// ### Design Notes
/// - Stores the string in a final [value] field for immutability.
/// - Supports safe conversion back to native Dart [String] via [toObject].
/// - Type-checking methods are consistent with the [JsonNode] interface.
/// {@endtemplate}
class JsonTextNode extends JsonNode {
  /// The underlying string value of this JSON node.
  final String value;

  /// Creates a new [JsonTextNode] wrapping the given [value].
  ///
  /// ### Example
  /// ```dart
  /// final node = JsonTextNode('Alice');
  /// print(node.value); // 'Alice'
  /// ```
  /// 
  /// {@macro jetleaf_json_text_node}
  JsonTextNode(this.value);

  @override
  bool isObject() => false;

  @override
  bool isArray() => false;

  @override
  bool isTextual() => true;

  @override
  bool isNumber() => false;

  @override
  bool isBoolean() => false;

  @override
  bool isNull() => false;

  @override
  String toObject() => value;
}

/// {@template jetleaf_json_numeric_node}
/// Represents a **JSON numeric node** in the Dart JSON model.
///
/// This node wraps a numeric value (`int` or `double`) and provides
/// type-checking consistent with [JsonNode].
///
/// ### Usage Example
/// ```dart
/// final numNode = JsonNumberNode(42);
///
/// if (numNode.isNumber()) {
///   print(numNode.toObject()); // 42
/// }
/// ```
///
/// ### Behavior Overview
/// | Dart JSON Value | Internal Representation | Description |
/// |-----------------|------------------------|-------------|
/// | `42` | `value = 42` | Integer value |
/// | `3.14` | `value = 3.14` | Floating-point value |
///
/// ### Design Notes
/// - Stores the numeric value in a final [value] field for immutability.
/// - Supports conversion back to native Dart [num] via [toObject].
/// - Type-checking methods align with the [JsonNode] interface.
/// {@endtemplate}
class JsonNumberNode extends JsonNode {
  /// The numeric value of this JSON node.
  final num value;

  /// {@macro jetleaf_json_numeric_node}
  ///
  /// Creates a new [JsonNumberNode] wrapping the given numeric [value].
  ///
  /// ### Example
  /// ```dart
  /// final node = JsonNumberNode(3.14);
  /// print(node.value); // 3.14
  /// ```
  JsonNumberNode(this.value);

  @override
  bool isObject() => false;

  @override
  bool isArray() => false;

  @override
  bool isTextual() => false;

  @override
  bool isNumber() => true;

  @override
  bool isBoolean() => false;

  @override
  bool isNull() => false;

  @override
  num toObject() => value;
}

/// {@template jetleaf_json_boolean_node}
/// Represents a **JSON boolean node** (`true` or `false`) in the Dart JSON model.
///
/// This node wraps a [bool] value and provides type-checking consistent with
/// [JsonNode].
///
/// ### Usage Example
/// ```dart
/// final boolNode = JsonBooleanNode(true);
///
/// if (boolNode.isBoolean()) {
///   print(boolNode.toObject()); // true
/// }
/// ```
///
/// ### Behavior Overview
/// | Dart JSON Value | Internal Representation | Description |
/// |-----------------|------------------------|-------------|
/// | `true` | `value = true` | Boolean true |
/// | `false` | `value = false` | Boolean false |
///
/// ### Design Notes
/// - Stores the boolean value in a final [value] field for immutability.
/// - Supports conversion back to native Dart [bool] via [toObject].
/// - Type-checking methods align with the [JsonNode] interface.
/// {@endtemplate}
class JsonBooleanNode extends JsonNode {
  /// The boolean value of this JSON node.
  final bool value;

  /// {@macro jetleaf_json_boolean_node}
  ///
  /// Creates a new [JsonBooleanNode] wrapping the given boolean [value].
  ///
  /// ### Example
  /// ```dart
  /// final node = JsonBooleanNode(false);
  /// print(node.value); // false
  /// ```
  JsonBooleanNode(this.value);

  @override
  bool isObject() => false;

  @override
  bool isArray() => false;

  @override
  bool isTextual() => false;

  @override
  bool isNumber() => false;

  @override
  bool isBoolean() => true;

  @override
  bool isNull() => false;

  @override
  bool toObject() => value;
}

/// {@template jetleaf_json_null_node}
/// Represents a **JSON null node** (`null`) in the Dart JSON model.
///
/// This node indicates the absence of a value and behaves consistently
/// with [JsonNode] type-checking methods.
///
/// ### Usage Example
/// ```dart
/// final nullNode = JsonNullNode();
///
/// if (nullNode.isNull()) {
///   print(nullNode.toObject()); // null
/// }
/// ```
///
/// ### Behavior Overview
/// | Dart JSON Value | Internal Representation | Description |
/// |-----------------|------------------------|-------------|
/// | `null` | `JsonNullNode()` | Represents a null value |
///
/// ### Design Notes
/// - This class is immutable and uses a `const` constructor.
/// - [toObject] returns Dart `null`.
/// - Type-checking is consistent with [JsonNode] interface.
/// {@endtemplate}
class JsonNullNode extends JsonNode {
  /// {@macro jetleaf_json_null_node}
  ///
  /// Creates a new [JsonNullNode] representing JSON `null`.
  const JsonNullNode();

  @override
  bool isObject() => false;

  @override
  bool isArray() => false;

  @override
  bool isTextual() => false;

  @override
  bool isNumber() => false;

  @override
  bool isBoolean() => false;

  @override
  bool isNull() => true;

  @override
  Object toObject() => Null();
}