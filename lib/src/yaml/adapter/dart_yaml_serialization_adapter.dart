import 'package:jetleaf_lang/lang.dart';

import '../../jetson_utils.dart';
import '../context/yaml_deserialization_context.dart';
import '../context/yaml_serialization_context.dart';
import '../generator/yaml_generator.dart';
import 'yaml_adapter.dart';
import '../parser/yaml_parser.dart';
import '../yaml_token.dart';

final class DartYamlSerializationAdapter extends YamlSerializationAdapter<Object> {
  final Class _class;

  DartYamlSerializationAdapter(this._class);

  @override
  bool canDeserialize(Class type) => type == _class || type.getType() == _class.getType();

  @override
  Object? deserialize(YamlParser parser, YamlDeserializationContext ctxt, Class toClass) {
    final fieldValues = <String, Object>{};
    
    while (parser.nextToken()) {
      if (parser.getCurrentToken() == YamlToken.MAPPING_END) {
        break;
      }
      
      if (parser.getCurrentToken() == YamlToken.KEY) {
        final key = parser.getCurrentValue()?.toString();
        parser.nextToken(); // Move to value
        
        if (key != null) {
          final dartName = ctxt.getNamingStrategy().toDartName(key);
          final field = _class.getField(dartName);
          
          if (field != null) {
            final fieldClass = field.getReturnClass();
            final value = ctxt.deserialize(parser, fieldClass);
            fieldValues[dartName] = value;
          }
        }
      }
    }
    
    return JetsonUtils.construct(fieldValues, _class);
  }

  @override
  bool canSerialize(Class type) => type == _class || type.getType() == _class.getType();

  @override
  void serialize(Object? value, YamlGenerator generator, YamlSerializationContext serializer) {
    generator.writeStartMapping();
    
    final fields = _class.getFields();
    for (final field in fields) {
      final fieldName = serializer.getNamingStrategy().toJsonName(field.getName());
      final fieldValue = field.getValue(value);
      
      generator.writeKey(fieldName);
      serializer.serialize(fieldValue, generator);
    }
    
    generator.writeEndMapping();
  }

  @override
  Class<Object> toClass() => Class.fromQualifiedName(_class.getQualifiedName());
}