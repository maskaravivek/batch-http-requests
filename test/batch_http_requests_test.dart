import 'dart:developer';

import 'package:batch_http_requests/batch_http_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () async {
    final requests = BatchHttpRequests();
    var response = await requests.getResponse(
        "https://imy21jqku1.execute-api.ap-south-1.amazonaws.com/prod/AloudNewsFeed",
        60);
    log(response);
  });
}
