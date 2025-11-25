import 'package:jetleaf_lang/lang.dart';

import '../../base/generator.dart';

/// {@template xml_generator}
/// Provides structured, incremental XML output for JetLeaf's serialization engine.
///
/// The [XmlGenerator] supports element boundaries, attributes, text content,
/// and raw XML injection for custom serialization cases.
///
/// ### Example
/// ```dart
/// final generator = StringXmlGenerator();
/// generator.writeStartElement('user');
/// generator.writeAttribute('id', '1');
/// generator.writeStartElement('name');
/// generator.writeText('Alice');
/// generator.writeEndElement(); // name
/// generator.writeEndElement(); // user
///
/// print(generator.toXmlString());
/// // Output: <user id="1"><name>Alice</name></user>
/// ```
/// {@endtemplate}
abstract interface class XmlGenerator implements Generator {
  static final Class<XmlGenerator> CLASS = Class<XmlGenerator>(null, PackageNames.JETSON);

  /// Writes the start of an XML element with the given [name].
  void writeStartElement(String name);

  /// Writes the end of the current XML element.
  void writeEndElement();

  /// Writes an attribute with the given [name] and [value].
  /// Must be called immediately after [writeStartElement].
  void writeAttribute(String name, String value);

  /// Writes a null value (typically as empty element or omitted).
  void writeNull();
}