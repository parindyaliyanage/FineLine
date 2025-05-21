import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  // List of passwords you need to hash
  final passwords = [
    '11223344',
    '1234thomas',
    '1234liyanage',
  ];

  for (var password in passwords) {
    final hashed = sha256.convert(utf8.encode(password)).toString();
    print('Original: $password => Hashed: $hashed');
  }
}