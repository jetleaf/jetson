// ignore_for_file: prefer_final_fields

import 'xml_node.dart';

/// Implementation of [XmlNode] representing text content.
final class XmlTextNode implements XmlNode<String> {
  final String _text;
  XmlNode? _parent;

  XmlTextNode(this._text, [this._parent]);

  @override
  String? getName() => null;

  @override
  String? getText() => _text;

  @override
  XmlNode? get(String name) => null;

  @override
  List<XmlNode> getAll(String name) => [];

  @override
  String? getAttribute(String name) => null;

  @override
  Map<String, String> getAttributes() => {};

  @override
  List<XmlNode> getChildren() => [];

  @override
  XmlNode? getParent() => _parent;

  @override
  String toObject() => _text;
}