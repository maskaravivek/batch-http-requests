import 'dart:convert';

import 'package:crypto/crypto.dart';

class Utils {
  static String hash(String value) {
    var key = utf8.encode('batch_http_requests');
    var bytes = utf8.encode(value);

    var hmacSha256 = new Hmac(sha256, key); // HMAC-SHA256
    return hmacSha256.convert(bytes).toString();
  }
}
