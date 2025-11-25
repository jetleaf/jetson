import '../xml_token.dart';
import '../../base/parser.dart';

/// {@template xml_parser}
/// A **streaming XML reader** that sequentially exposes parsed XML tokens.
///
/// The [XmlParser] provides low-level, pull-based access to XML input,
/// allowing deserializers to process data incrementally without loading
/// entire documents into memory.
///
/// ### Overview
/// - Reads from strings, byte streams, or character sources
/// - Emits tokens ([XmlToken]) as it parses
/// - Allows skipping nested elements efficiently
///
/// ### See also
/// - [XmlToken]
/// - [XmlObjectMapper]
/// - [XmlNode]
/// {@endtemplate}
abstract interface class XmlParser implements Parser<XmlToken> {
  /// Returns the **current element name** if at an element token.
  ///
  /// Returns `null` for non-element tokens.
  String? getElementName();

  /// Returns the **attributes** of the current element as a map.
  ///
  /// Only valid when positioned at a START_ELEMENT token.
  Map<String, String> getAttributes();
}