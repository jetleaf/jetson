// ignore_for_file: prefer_final_fields

import 'yaml_node.dart';
import 'yaml_node_type.dart';

/// Implementation of [YamlNode] representing a scalar value.
final class YamlScalarNode implements YamlNode<String> {
  final String _value;
  // ignore: unused_field
  YamlNode? _parent;

  YamlScalarNode(this._value, [this._parent]);

  @override
  YamlNodeType getNodeType() => YamlNodeType.SCALAR;

  @override
  String? getText() => _value;

  @override
  YamlNode? get(String key) => null;

  @override
  List<YamlNode> getAll(String key) => [];

  @override
  List<String> getKeys() => [];

  @override
  List<YamlNode> getElements() => [];

  @override
  String toObject() => _value;
}