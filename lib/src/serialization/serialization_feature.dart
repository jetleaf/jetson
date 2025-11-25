/// Feature flags that influence **serialization behavior** in JetLeaf.
///
/// These options control how values, structures, and formatting are handled
/// when converting Dart objects into JSON output.
///
/// ### Example
/// ```dart
/// final mapper = ObjectMapper()
///   ..enable(SerializationFeature.INDENT_OUTPUT)
///   ..disable(SerializationFeature.WRITE_NULL_MAP_VALUES);
/// ```
///
/// ### Notes
/// - Features are toggled via [ObjectMapper.enable] / [ObjectMapper.disable].
/// - Default configuration is optimized for correctness and minimal output size.
///
/// ### See also
/// - [DeserializationFeature]
/// - [ObjectMapper]
enum SerializationFeature {
  /// Fails serialization when an empty object (with no writable properties)
  /// is encountered. Useful for strict schema validation.
  FAIL_ON_EMPTY,

  /// Serializes date and time values as **numeric timestamps** instead of
  /// ISO-8601 strings.
  ///
  /// When enabled, `DateTime(2025, 10, 28)` → `1730073600000`.
  WRITE_DATES_AS_TIMESTAMPS,

  /// Determines whether `null` entries in maps or fields should be written
  /// to the output JSON.
  ///
  /// - `true`: writes `"key": null`
  /// - `false`: omits the key entirely
  WRITE_NULL_MAP_VALUES,

  /// Enables human-readable, indented JSON output with line breaks.
  ///
  /// Useful for debugging, logging, or pretty-printed configuration files.
  INDENT_OUTPUT,

  /// Orders map entries by their keys in lexicographic order before writing.
  ///
  /// Ensures deterministic output for schema comparison and caching.
  ORDER_MAP_ENTRIES_BY_KEYS,

  /// Wraps the root value within an additional object named after its type.
  ///
  /// Example:
  /// ```json
  /// { "User": { "id": 1, "name": "Alice" } }
  /// ```
  WRAP_ROOT_VALUE,
}