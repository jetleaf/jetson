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
import 'package:jetson/src/base/object_mapper.dart';

final class Address {}

final class User {
  final String email;
  final String password;
  final Address address;

  const User(this.address, this.email, this.password);
}

void main() async {
  await runTestScan();
  final jetson = ObjectMapper();

  final value = jetson.readValue('{"email": "", "password": "", "address": {}}', Class<User>());
  print(value);
}