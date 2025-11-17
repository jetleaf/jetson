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

import 'dart:convert';

import 'package:jetson/src/json/string_json_generator.dart';
import 'package:test/test.dart';

void main() {
  group('StringJsonGenerator', () {
    group('Compact JSON (no pretty printing)', () {
      test('generates simple object with string', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Alice');
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"name":"Alice"}');
        
        // Verify it's valid JSON
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates simple object with multiple fields', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        gen.writeFieldName('name');
        gen.writeString('Alice');
        
        gen.writeFieldName('age');
        gen.writeNumber(30);
        
        gen.writeFieldName('active');
        gen.writeBoolean(true);
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"name":"Alice","age":30,"active":true}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates simple array', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        gen.writeString('a');
        gen.writeString('b');
        gen.writeString('c');
        gen.writeEndArray();

        final json = gen.toJsonString();
        expect(json, '["a","b","c"]');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates array of numbers', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        gen.writeNumber(1);
        gen.writeNumber(2.5);
        gen.writeNumber(3);
        gen.writeEndArray();

        final json = gen.toJsonString();
        expect(json, '[1,2.5,3]');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates nested objects', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        gen.writeFieldName('user');
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Alice');
        gen.writeFieldName('age');
        gen.writeNumber(30);
        gen.writeEndObject();
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"user":{"name":"Alice","age":30}}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates object with array', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        gen.writeFieldName('names');
        gen.writeStartArray();
        gen.writeString('Alice');
        gen.writeString('Bob');
        gen.writeEndArray();
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"names":["Alice","Bob"]}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates array of objects', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        
        gen.writeStartObject();
        gen.writeFieldName('id');
        gen.writeNumber(1);
        gen.writeFieldName('name');
        gen.writeString('Alice');
        gen.writeEndObject();
        
        gen.writeStartObject();
        gen.writeFieldName('id');
        gen.writeNumber(2);
        gen.writeFieldName('name');
        gen.writeString('Bob');
        gen.writeEndObject();
        
        gen.writeEndArray();

        final json = gen.toJsonString();
        expect(json, '[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('generates null values', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        gen.writeFieldName('value');
        gen.writeNull();
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"value":null}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('no trailing commas in objects', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('a');
        gen.writeNumber(1);
        gen.writeEndObject();

        final json = gen.toJsonString();
        // Should not end with '},' or have ',' before '}'
        expect(json.contains(',}'), false);
        expect(json.endsWith('}'), true);
      });

      test('no trailing commas in arrays', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        gen.writeNumber(1);
        gen.writeNumber(2);
        gen.writeEndArray();

        final json = gen.toJsonString();
        // Should not end with '],' or have ',' before ']'
        expect(json.contains(',]'), false);
        expect(json.endsWith(']'), true);
      });

      test('escapes special characters in strings', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('text');
        gen.writeString('Hello\nWorld\t"quoted"');
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"text":"Hello\\nWorld\\t\\"quoted\\""}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('escapes backslashes', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('path');
        gen.writeString('C:\\Users\\Alice');
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"path":"C:\\\\Users\\\\Alice"}');
        expect(() => jsonDecode(json), returnsNormally);
      });
    });

    group('Pretty printing', () {
      test('pretty prints simple object', () {
        final gen = StringJsonGenerator(pretty: true, indentSize: 2);
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Alice');
        gen.writeEndObject();

        final json = gen.toJsonString();
        // Should have newlines and indentation
        expect(json.contains('\n'), true);
        expect(json.contains('  '), true);
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('pretty prints nested objects', () {
        final gen = StringJsonGenerator(pretty: true, indentSize: 2);
        gen.writeStartObject();
        
        gen.writeFieldName('user');
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Alice');
        gen.writeEndObject();
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(() => jsonDecode(json), returnsNormally);
        expect(json.contains('\n'), true);
      });

      test('pretty prints arrays', () {
        final gen = StringJsonGenerator(pretty: true, indentSize: 2);
        gen.writeStartArray();
        gen.writeNumber(1);
        gen.writeNumber(2);
        gen.writeNumber(3);
        gen.writeEndArray();

        final json = gen.toJsonString();
        expect(() => jsonDecode(json), returnsNormally);
        expect(json.contains('\n'), true);
      });

      test('uses custom indent size', () {
        final gen = StringJsonGenerator(pretty: true, indentSize: 4);
        gen.writeStartObject();
        gen.writeFieldName('nested');
        gen.writeStartObject();
        gen.writeFieldName('value');
        gen.writeNumber(1);
        gen.writeEndObject();
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json.contains('    '), true); // 4-space indent
        expect(() => jsonDecode(json), returnsNormally);
      });
    });

    group('Complex scenarios', () {
      test('home object with address and tenants', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        gen.writeFieldName('id');
        gen.writeString('H001');
        
        gen.writeFieldName('owner');
        gen.writeString('Alice');
        
        gen.writeFieldName('address');
        gen.writeStartObject();
        gen.writeFieldName('street');
        gen.writeString('123 Elm Street');
        gen.writeFieldName('city');
        gen.writeString('Denver');
        gen.writeFieldName('zip');
        gen.writeString('80202');
        gen.writeEndObject();
        
        gen.writeFieldName('tenants');
        gen.writeStartArray();
        
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Bob');
        gen.writeFieldName('age');
        gen.writeNumber(29);
        gen.writeEndObject();
        
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Charlie');
        gen.writeFieldName('age');
        gen.writeNumber(35);
        gen.writeEndObject();
        
        gen.writeEndArray();
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        
        // Verify structure
        expect(json.contains('"id":"H001"'), true);
        expect(json.contains('"owner":"Alice"'), true);
        expect(json.contains('"street":"123 Elm Street"'), true);
        expect(json.contains('"name":"Bob"'), true);
        expect(json.contains('"name":"Charlie"'), true);
        
        // Verify no trailing commas
        expect(json.contains(',}'), false);
        expect(json.contains(',]'), false);
        
        // Verify valid JSON
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('deeply nested structure', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('level1');
        gen.writeStartObject();
        gen.writeFieldName('level2');
        gen.writeStartObject();
        gen.writeFieldName('level3');
        gen.writeNumber(42);
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"level1":{"level2":{"level3":42}}}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('mixed arrays and objects', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        gen.writeFieldName('items');
        gen.writeStartArray();
        
        gen.writeStartObject();
        gen.writeFieldName('id');
        gen.writeNumber(1);
        gen.writeFieldName('tags');
        gen.writeStartArray();
        gen.writeString('tag1');
        gen.writeString('tag2');
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeEndArray();
        
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{"items":[{"id":1,"tags":["tag1","tag2"]}]}');
        expect(() => jsonDecode(json), returnsNormally);
      });
    });

    group('Edge cases and error handling', () {
      test('throws on mismatched end array', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        
        expect(
          () => gen.writeEndArray(),
          throwsStateError,
        );
      });

      test('throws on mismatched end object', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        
        expect(
          () => gen.writeEndObject(),
          throwsStateError,
        );
      });

      test('throws on field name in array', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        
        expect(
          () => gen.writeFieldName('invalid'),
          throwsStateError,
        );
      });

      test('throws if toJsonString called with unclosed structure', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('name');
        gen.writeString('Alice');
        // Missing writeEndObject()
        
        expect(
          () => gen.toJsonString(),
          throwsStateError,
        );
      });

      test('can reuse generator after toJsonString', () {
        final gen = StringJsonGenerator();
        
        // First use
        gen.writeStartObject();
        gen.writeFieldName('a');
        gen.writeNumber(1);
        gen.writeEndObject();
        final json1 = gen.toJsonString();
        
        // Second use (should work)
        gen.writeStartObject();
        gen.writeFieldName('b');
        gen.writeNumber(2);
        gen.writeEndObject();
        final json2 = gen.toJsonString();
        
        expect(json1, '{"a":1}');
        expect(json2, '{"b":2}');
      });

      test('handles empty objects', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json, '{}');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('handles empty arrays', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        gen.writeEndArray();

        final json = gen.toJsonString();
        expect(json, '[]');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('handles special float values', () {
        final gen = StringJsonGenerator();
        gen.writeStartArray();
        gen.writeNumber(3.14159);
        gen.writeNumber(0.0);
        gen.writeNumber(-42.5);
        gen.writeEndArray();

        final json = gen.toJsonString();
        expect(() => jsonDecode(json), returnsNormally);
      });
    });

    group('String escaping', () {
      test('escapes all control characters', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('control');
        gen.writeString('tab:\t newline:\n carriage:\r');
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json.contains('\\t'), true);
        expect(json.contains('\\n'), true);
        expect(json.contains('\\r'), true);
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('escapes quotes correctly', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('quote');
        gen.writeString('She said "Hello"');
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(json.contains('\\"'), true);
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('handles backspace and form feed', () {
        final gen = StringJsonGenerator();
        gen.writeStartObject();
        gen.writeFieldName('special');
        gen.writeString('backspace:\b formfeed:\f');
        gen.writeEndObject();

        final json = gen.toJsonString();
        expect(() => jsonDecode(json), returnsNormally);
      });
    });
  });
}
