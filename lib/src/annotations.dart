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

import 'package:jetleaf_lang/lang.dart';
import 'package:meta/meta_meta.dart';

import 'serialization/object_serializable.dart';

/// {@template json_converter}
/// Annotation used to associate a custom JSON converter with a class field or property.
///
/// This is especially useful when a field cannot be serialized or deserialized
/// using the default behavior and needs a specific [ObjectSerializable] implementation.
///
/// The [converter] should point to a class that extends [ObjectSerializable<T>].
///
/// ### Example:
/// ```dart
/// class MyModel {
///   @JsonConverter(type: ClassType<DateTimeAdapter>(null, "package:jetleaf_lang/lang.dart"))
///   final DateTime createdAt;
///
///   MyModel(this.createdAt);
/// }
/// ```
/// When deserializing `MyModel`, the `DateTimeAdapter` will be used to convert
/// the `createdAt` field instead of the default strategy.
///
/// This annotation is part of the Jetleaf Reflection system.
/// {@endtemplate}
@Generic(JsonConverter)
@Target({TargetKind.field, TargetKind.getter, TargetKind.setter})
class JsonConverter<T extends ObjectSerializable> extends ReflectableAnnotation {
  /// The type of the converter class to use for (de)serialization.
  ///
  /// Must be a subclass of [ObjectSerializable].
  final ClassType<T>? type;

  /// Optional instance of a converter to use directly.
  final ObjectSerializable? converter;
  
  /// Creates a new [JsonConverter] annotation.
  ///
  /// The [type] parameter must not be null.
  /// 
  /// {@macro json_converter}
  const JsonConverter({this.converter, this.type});
  
  @override
  Type get annotationType => JsonConverter;
}

/// {@template json_creator}
/// Annotation to designate a constructor as the primary entry point for JSON deserialization.
///
/// Use this annotation when a class has multiple constructors, and you want to explicitly
/// specify which one should be used during deserialization from a JSON structure.
///
/// This is particularly useful in combination with reflection-based serializers where
/// constructor selection is ambiguous or not guaranteed.
///
/// ### Example:
/// ```dart
/// class User {
///   final String name;
///   final int age;
///
///   User(this.name, this.age);
///
///   @JsonCreator()
///   factory User.fromJson(Map<String, dynamic> json) {
///     return User(
///       json['name'] as String,
///       json['age'] as int,
///     );
///   }
/// }
/// ```
/// In the above example, the `fromJson` factory is marked with `@JsonCreator`,
/// indicating it should be used when deserializing a `User` object from JSON.
///
/// This annotation is part of the Jetleaf Reflection system.
/// {@endtemplate}
@Target({TargetKind.constructor, TargetKind.method})
class JsonCreator extends ReflectableAnnotation {
  /// Creates a new [JsonCreator] annotation.
  ///
  /// Apply this to a constructor or factory method to indicate it's used
  /// for JSON deserialization.
  /// 
  /// {@macro json_creator}
  const JsonCreator();
  
  @override
  Type get annotationType => JsonCreator;
}

/// {@template json_field}
/// Annotation to customize how a class field is serialized to and deserialized from JSON.
///
/// This annotation is used to provide fine-grained control over JSON mapping
/// for individual fields in a Dart class when using Jetleaf's reflection-based
/// serialization system.
///
/// It can be applied to fields to rename them in JSON, mark them as required,
/// ignore them, or provide a default value during deserialization.
///
/// ### Example:
/// ```dart
/// class User {
///   @JsonField(name: 'user_name')
///   final String username;
/// 
///   @JsonField(ignore: true)
///   final String password;
/// 
///   @JsonField(required: true)
///   final int age;
/// 
///   @JsonField(defaultValue: 'N/A')
///   final String? bio;
/// 
///   User(this.username, this.password, this.age, this.bio);
/// }
/// ```
/// In this example:
/// - `username` is serialized/deserialized using the key `user_name`.
/// - `password` will be ignored completely during (de)serialization.
/// - `age` must be present in the JSON map or deserialization will fail.
/// - `bio` will default to `'N/A'` if not provided in the JSON input.
///
/// {@endtemplate}
@Target({TargetKind.field, TargetKind.getter, TargetKind.setter})
class JsonField extends ReflectableAnnotation {
  /// {@template json_field.name}
  /// Custom name for the JSON field.
  ///
  /// If set, this overrides the field name used during serialization and deserialization.
  /// {@endtemplate}
  final String? name;

  /// {@template json_field.ignore}
  /// Whether this field should be excluded from both serialization and deserialization.
  ///
  /// When `true`, the field is completely ignored by the serializer.
  /// {@endtemplate}
  final bool ignore;

  /// {@template json_field.required}
  /// Whether this field must be present in the input JSON during deserialization.
  ///
  /// If the field is missing and no [defaultValue] is set, deserialization will throw an error.
  /// {@endtemplate}
  final bool required;

  /// {@template json_field.defaultValue}
  /// A fallback value to assign if the field is missing during deserialization.
  ///
  /// Only used if the field is not marked as `required`.
  /// {@endtemplate}
  final Object? defaultValue;

  /// Creates a [JsonField] annotation to customize field (de)serialization behavior.
  ///
  /// - [name]: Override the JSON key name.
  /// - [ignore]: Exclude this field from JSON operations.
  /// - [required]: Require the field during deserialization.
  /// - [defaultValue]: Fallback value if missing from JSON input.
  /// 
  /// {@macro json_field}
  const JsonField({this.name, this.ignore = false, this.required = false, this.defaultValue});
  
  @override
  Type get annotationType => JsonField;
}

/// {@template json_ignore}
/// Marks a Dart field, getter, or setter to be **ignored during JSON
/// serialization and deserialization**.
///
/// When applied, the annotated member will be skipped by the object mapper,
/// meaning it will not appear in the JSON output and will not be populated
/// when deserializing from JSON.
///
/// ### Usage Example
/// ```dart
/// class User {
///   String name;
///
///   @JsonIgnore()
///   String password;
///
///   User(this.name, this.password);
/// }
///
/// final user = User('Alice', 'secret');
/// final json = objectMapper.writeValueAsString(user);
/// print(json); // {"name":"Alice"} (password is omitted)
/// ```
///
/// ### Design Notes
/// - Can be applied to fields, getters, or setters only, enforced by
///   [@Target].
/// {@endtemplate}
@Target({TargetKind.field, TargetKind.getter, TargetKind.setter})
class JsonIgnore extends ReflectableAnnotation {
  /// {@macro json_ignore}
  ///
  /// Creates a constant [JsonIgnore] annotation to skip a field
  /// during JSON serialization and deserialization.
  const JsonIgnore();

  @override
  Type get annotationType => JsonIgnore;
}

/// {@template jetleaf_from_json}
/// A **constraint annotation** for generating instances of a class from a
/// JSON map representation.
///
/// The [FromJson] annotation is applied to a class to indicate that it can be
/// instantiated from a `Map<String, Object?>`. It requires a `creator` function
/// that converts the JSON map into an instance of the annotated type.
///
/// This annotation is often used in conjunction with **reflection-based or
/// code-generated deserialization frameworks** to automatically convert JSON
/// data into typed Dart objects.
///
/// ### Parameters
/// - `creator` – A function that takes a `Map<String, Object?>` and returns an
///   instance of type `T`.
///
/// ### Example
/// ```dart
/// @FromJson(User.fromMap)
/// class User {
///   final String name;
///   final int age;
///
///   User(this.name, this.age);
///
///   static User fromMap(Map<String, Object?> json) {
///     return User(
///       json['name'] as String,
///       json['age'] as int,
///     );
///   }
/// }
///
/// final user = User.fromMap({'name': 'Alice', 'age': 30});
/// ```
///
/// ### Design Notes
/// - Targets only class types ([TargetKind.classType]).
/// - Useful in serialization/deserialization libraries that rely on a
///   unified mapping from JSON to objects.
/// - Does **not** perform validation; it only provides a factory function.
///
/// {@endtemplate}
@Generic(FromJson)
@Target({TargetKind.classType})
class FromJson<T> extends ReflectableAnnotation {
  /// A function that converts a JSON map to an instance of the annotated class.
  final T Function(Map<String, Object>) creator;

  /// Constructs a [FromJson] annotation with the given `creator` function.
  const FromJson(this.creator);

  @override
  Type get annotationType => FromJson;
}

/// {@template jetleaf_to_json}
/// A **constraint annotation** for converting an instance of a class to a
/// JSON map representation.
///
/// The [ToJson] annotation is applied to a class to indicate that it can be
/// serialized into a `Map<String, Object?>`. It requires a `creator` function
/// that converts an instance of the class into a JSON map.
///
/// This annotation is often used in conjunction with **reflection-based or
/// code-generated serialization frameworks** to automatically convert Dart
/// objects into JSON-compatible maps.
///
/// ### Parameters
/// - `creator` – A function that takes an instance of the class and returns a
///   `Map<String, Object?>`.
///
/// ### Example
/// ```dart
/// @ToJson(User.toMap)
/// class User {
///   final String name;
///   final int age;
///
///   User(this.name, this.age);
///
///   static Map<String, Object?> toMap(User user) {
///     return {
///       'name': user.name,
///       'age': user.age,
///     };
///   }
/// }
///
/// final json = User.toMap(User('Alice', 30));
/// ```
///
/// ### Design Notes
/// - Targets only class types ([TargetKind.classType]).
/// - Useful in serialization/deserialization libraries that rely on a
///   unified mapping from objects to JSON.
/// - Does **not** perform validation; it only provides a mapping function.
///
/// {@endtemplate}
@Generic(ToJson)
@Target({TargetKind.classType})
class ToJson<T> extends ReflectableAnnotation {
  /// A function that converts an instance of the annotated class to a JSON map.
  final Map<String, Object> Function(Object) creator;

  /// Constructs a [ToJson] annotation with the given `creator` function.
  const ToJson(this.creator);

  @override
  Type get annotationType => ToJson;
}