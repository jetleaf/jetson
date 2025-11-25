/// {@template jetson_object_mapper_type}
/// Specifies the **data format** handled by a particular [ObjectMapper]
/// instance.
///
/// Jetson supports multiple serialization formats, and each implementation
/// of [ObjectMapper] is associated with exactly one of these types.
///
/// This enum is used internally by Jetson to:
/// - Select the correct generator and parser (e.g., `JsonGenerator`, `YamlParser`)
/// - Determine which serializer/deserializer pairs to apply
/// - Drive format-specific configuration and feature flags
///
/// Applications may also use it when constructing or selecting mappers
/// dynamically (e.g., switching between JSON and YAML output).
///
/// ### Example
/// ```dart
/// final mapper = JetsonObjectMapper.forType(ObjectMapperType.JSON);
/// print(mapper.type); // ObjectMapperType.JSON
/// ```
///
/// ### Formats
/// - **JSON** — Standard JavaScript Object Notation  
/// - **XML** — Extensible Markup Language  
/// - **YAML** — YAML Ain’t Markup Language  
///
/// {@endtemplate}
enum ObjectMapperType {
  /// {@macro jetson_object_mapper_type}
  JSON,

  /// {@macro jetson_object_mapper_type}
  XML,

  /// {@macro jetson_object_mapper_type}
  YAML,
}