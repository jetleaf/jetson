// ignore_for_file: prefer_final_fields

import 'yaml_node.dart';
import 'yaml_node_type.dart';

/// Implementation of [YamlNode] representing a YAML mapping (object).
final class YamlMappingNode implements YamlNode<Map<String, dynamic>> {
  final Map<String, YamlNode> _children;
  // ignore: unused_field
  YamlNode? _parent;

  YamlMappingNode(this._children, [this._parent]);

  @override
  YamlNodeType getNodeType() => YamlNodeType.MAPPING;

  @override
  String? getText() => null;

  @override
  YamlNode? get(String key) => _children[key];

  @override
  List<YamlNode> getAll(String key) {
    final node = _children[key];
    return node != null ? [node] : [];
  }

  @override
  List<String> getKeys() => _children.keys.toList();

  @override
  List<YamlNode> getElements() => [];

  @override
  Map<String, dynamic> toObject() {
    return _children.map((key, value) => MapEntry(key, value.toObject()));
  }
}