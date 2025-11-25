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