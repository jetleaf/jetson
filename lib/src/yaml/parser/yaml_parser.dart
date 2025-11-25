import '../yaml_token.dart';
import '../../base/parser.dart';

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
abstract interface class YamlParser implements Parser<YamlToken> {
  /// Returns the **anchor name** if this token is anchored.
  ///
  /// For tokens with anchors (e.g., `&anchor value`), returns the anchor name.
  /// Returns `null` if no anchor is present.
  String? getAnchor();

  /// Returns the **alias reference** if this token is an alias.
  ///
  /// For ALIAS tokens, returns the referenced anchor name.
  String? getAlias();
}