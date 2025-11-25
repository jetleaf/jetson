/// Feature flags that influence **deserialization behavior** in JetLeaf.
///
/// These options determine how JSON input is interpreted, validated,
/// and transformed into Dart objects.
///
/// ### Example
/// ```dart
/// final mapper = ObjectMapper()
///   ..enable(DeserializationFeature.ACCEPT_EMPTY_STRINGS_AS_NULL)
///   ..disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
/// ```
///
/// ### Notes
/// - Features provide compatibility and fault-tolerance for varying JSON formats.
/// - Most options mirror Jackson’s configuration model for familiarity.
///
/// ### See also
/// - [SerializationFeature]
/// - [ObjectMapper]
enum DeserializationFeature {
  /// Throws an error when encountering unknown JSON properties
  /// that do not map to any field in the target class.
  FAIL_ON_UNKNOWN_PROPERTIES,

  /// Allows `//` and `/* */` comments inside JSON documents.
  ///
  /// Non-standard, but useful for configuration files or relaxed parsing.
  ALLOW_COMMENTS,

  /// Permits the use of single quotes (`'value'`) for strings
  /// in addition to standard double quotes.
  ALLOW_SINGLE_QUOTES,

  /// Fails when a required constructor or factory parameter
  /// (creator property) is missing from input JSON.
  FAIL_ON_MISSING_CREATOR_PROPERTIES,

  /// Interprets empty strings (`""`) as `null` for non-string fields.
  ///
  /// Example:
  /// ```json
  /// { "user": "" } → { "user": null }
  /// ```
  ACCEPT_EMPTY_STRINGS_AS_NULL,

  /// Adjusts parsed `DateTime` values to the context’s configured time zone
  /// (see [ObjectMapper.TIMEZONE_PROPERTY]).
  ADJUST_DATES_TO_CONTEXT_TIME_ZONE,
}