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