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

import 'package:test/test.dart';
import 'package:jetson/src/json/string_json_parser.dart';
import 'package:jetson/src/base.dart';

void main() {
  test('parses simple object tokens in expected order', () {
    final json = '{"email":"frank@gmail.com","name":"user"}';
    final parser = StringJsonParser(json);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.START_OBJECT);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.FIELD_NAME);
    expect(parser.getCurrentName(), 'email');

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.VALUE_STRING);
    expect(parser.getCurrentValue(), 'frank@gmail.com');

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.FIELD_NAME);
    expect(parser.getCurrentName(), 'name');

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.VALUE_STRING);
    expect(parser.getCurrentValue(), 'user');

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.END_OBJECT);

    // no more tokens
    expect(parser.nextToken(), isFalse);
  });

  test('parses nested object ordering', () {
    final json = '{"outer": {"a": 1}, "b": 2}';
    final parser = StringJsonParser(json);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.START_OBJECT);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.FIELD_NAME);
    expect(parser.getCurrentName(), 'outer');

    // entering nested object: should immediately present START_OBJECT for the child
    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.START_OBJECT);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.FIELD_NAME);
    expect(parser.getCurrentName(), 'a');

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.VALUE_NUMBER);
    expect(parser.getCurrentValue(), 1);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.END_OBJECT);

    // back to parent: next field 'b'
    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.FIELD_NAME);
    expect(parser.getCurrentName(), 'b');

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.VALUE_NUMBER);
    expect(parser.getCurrentValue(), 2);

    expect(parser.nextToken(), isTrue);
    expect(parser.getCurrentToken(), JsonToken.END_OBJECT);

    expect(parser.nextToken(), isFalse);
  });

  test('parses primitive root values', () {
    final s = StringJsonParser('"hello"');
    expect(s.nextToken(), isTrue);
    expect(s.getCurrentToken(), JsonToken.VALUE_STRING);
    expect(s.getCurrentValue(), 'hello');
    expect(s.nextToken(), isFalse);

    final n = StringJsonParser('123');
    expect(n.nextToken(), isTrue);
    expect(n.getCurrentToken(), JsonToken.VALUE_NUMBER);
    expect(n.getCurrentValue(), 123);
    expect(n.nextToken(), isFalse);
  });
}
