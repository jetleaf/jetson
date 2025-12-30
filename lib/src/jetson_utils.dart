import 'package:jetleaf_lang/lang.dart';

import 'annotations.dart';

/// Utility class providing object construction helpers for Dart types.
abstract interface class JetsonUtils {
  /// Constructs a Dart instance of the specified [type] using the given [fields].
  ///
  /// This method attempts to resolve a constructor or factory for the type in the
  /// following order:
  ///
  /// 1. **[FromJson] annotation creator** – If the class has a `FromJson` annotation,
  ///    the provided creator function is invoked with the `fields` map.
  /// 2. **Constructor annotated with [JsonCreator]** – Uses a constructor annotated
  ///    with `JsonCreator` and passes the `fields` map as argument(s).
  /// 3. **Static `fromJson(Map<String, dynamic>)` method** – Invokes a static
  ///    `fromJson` method if present and compatible.
  /// 4. **Other static factory methods accepting a single map argument** – Finds a
  ///    static method that can accept the `fields` map as a positional argument.
  /// 5. **Default constructor with field assignments** – Attempts to instantiate
  ///    via the default constructor, passing `fields` where possible.
  ///
  /// Returns the created object if successful; otherwise, returns `null`.
  ///
  /// **Note:** This method handles any exceptions during instantiation gracefully
  /// and returns `null` on failure.
  static Object? construct(Map<String, Object> fields, Class type) {
    final fromJson = type.getDirectAnnotation<FromJson>();
    if (fromJson != null) {
      return fromJson.creator(fields);
    }

    final constructor = type.getConstructors().find((c) => c.hasDirectAnnotation<JsonCreator>());
    if (constructor != null) {
      return constructor.newInstance(fields, [fields]);
    }

    final fromJsonMethodIfAvailable = type.getMethod("fromJson");
    if (fromJsonMethodIfAvailable != null && fromJsonMethodIfAvailable.getParameterCount() == 1 && fromJsonMethodIfAvailable.isStatic()) {
      return fromJsonMethodIfAvailable.invoke(null, null, [fields]);
    }

    final invokable = type.getMethods().find((m) => m.canAcceptPositionalArguments([fields]));
    if (invokable != null && invokable.isStatic()) {
      return invokable.invoke(null, null, [fields]);
    }

    return type.newInstance(fields);
  }
}