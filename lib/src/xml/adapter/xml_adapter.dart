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

import '../../serialization/deserialization_context.dart';
import '../../serialization/object_deserializer.dart';
import '../../serialization/object_serialization_adapter.dart';
import '../../serialization/object_serializer.dart';
import '../../serialization/serialization_context.dart';
import '../context/xml_deserialization_context.dart';
import '../context/xml_serialization_context.dart';
import '../generator/xml_generator.dart';
import '../parser/xml_parser.dart';

/// {@template xml_deserializer}
/// Specialization of [ObjectDeserializer] for XML deserialization using [XmlParser].
/// {@endtemplate}
@Generic(XmlDeserializer)
abstract interface class XmlDeserializer<T> implements ObjectDeserializer<T, XmlParser, XmlDeserializationContext> {}

/// {@template xml_serializer}
/// Specialization of [ObjectSerializer] for XML serialization using [XmlGenerator].
/// {@endtemplate}
@Generic(XmlSerializer)
abstract interface class XmlSerializer<T> implements ObjectSerializer<T, XmlGenerator, XmlSerializationContext> {}

/// {@template xml_converter_adapter}
/// Bidirectional XML converter implementing both serialization and deserialization.
/// {@endtemplate}
@Generic(XmlSerializationAdapter)
abstract class XmlSerializationAdapter<T> implements ObjectSerializationAdapter<T, XmlGenerator, XmlParser, XmlDeserializationContext, XmlSerializationContext> {
  static final Class<XmlSerializationAdapter> CLASS = Class<XmlSerializationAdapter>(null, PackageNames.JETSON);

  const XmlSerializationAdapter();

  @override
  bool supports(DeserializationContext context) => context is XmlDeserializationContext;

  @override
  bool supportsContext(SerializationContext context) => context is XmlSerializationContext;
}