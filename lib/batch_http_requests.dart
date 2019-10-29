library batch_http_requests;

import 'dart:convert';
import 'dart:io';

import 'package:batch_http_requests/http_tuple.dart';
import 'package:batch_http_requests/requests_database.dart';
import 'package:dio/dio.dart';

class BatchHttpRequests {
  RequestsDatabase database;
  Dio _dio;

  BatchHttpRequests() {
    this.database = RequestsDatabase();
    BaseOptions options =
        BaseOptions(receiveTimeout: 60000, connectTimeout: 60000);
    _dio = Dio(options);
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<String> getResponse(String url) async {
    HttpTuple response = await _getFromDB(url);

    if (response != null && response.status == 'SUCCESS') {
      print("Returning API response from DB");
      return response.response;
    }
    return await _getFromHttp(url);
  }

  Future<String> postResponse(String url, String data) async {
    HttpTuple response = await _postFromDB(url, data);
    print("response from DB is: " + response.toString());
    if (response != null && response.status == 'SUCCESS') {
      print("Returning API response from DB");
      return response.response;
    }
    return await _postFromHttp(url, data);
  }

  Future<String> _getFromHttp(String url) async {
    Response httpResponse = await _dio.get(url);
    var response = jsonEncode(httpResponse.data);
    database.updateRequest(url, response);
    return response;
  }

  Future<String> _postFromHttp(String url, String data) async {
    Response httpResponse = await _dio.post(url, data: data, options:
    new Options(contentType: ContentType.parse("application/json")));
    var response = jsonEncode(httpResponse.data);
    database.updateRequestWithData(
        url, data, response);
    return response;
  }

  Future<HttpTuple> _getFromDB(String url) async {
    HttpTuple response = await database.getResponseFromDB(url);
    if (response == null) {
      database.insertRequest(new HttpTuple(url));
    }
    return response;
  }

  Future<HttpTuple> _postFromDB(String url, String data) async {
    HttpTuple response = await database.getResponseFromDBWithData(url, data);
    if (response == null) {
      database.insertRequest(
          new HttpTuple.withUrlData(url, data));
    }
    return response;
  }
}
