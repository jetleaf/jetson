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

import '../context/xml_deserialization_context.dart';
import '../context/xml_serialization_context.dart';
import '../generator/xml_generator.dart';
import '../parser/xml_parser.dart';
import '../xml_token.dart';
import 'xml_adapter.dart';

final class MapXmlSerializationAdapter extends XmlSerializationAdapter<Map> {
  const MapXmlSerializationAdapter();

  @override
  bool canDeserialize(Class type) => type == Class<Map>() || type.getType() == Map;

  @override
  Map? deserialize(XmlParser parser, XmlDeserializationContext ctxt, Class toClass) {
    final map = <String, Object>{};
    
    while (parser.nextToken()) {
      if (parser.getCurrentToken() == XmlToken.END_ELEMENT) {
        break;
      }
      
      if (parser.getCurrentToken() == XmlToken.START_ELEMENT) {
        final key = parser.getElementName() ?? 'unknown';
        final valueType = toClass.componentType() ?? Class<Object>();
        final value = ctxt.deserialize(parser, valueType);
        map[key] = value;
      }
    }
    
    return map;
  }

  @override
  bool canSerialize(Class type) => type == Class<Map>() || type.getType() == Map;

  @override
  void serialize(Map value, XmlGenerator generator, XmlSerializationContext serializer) {
    for (final entry in value.entries) {
      final key = entry.key.toString();
      generator.writeStartElement(key);
      serializer.serialize(entry.value, generator);
      generator.writeEndElement();
    }
  }

  @override
  Class<Map> toClass() => Class<Map>(null, PackageNames.DART);
}