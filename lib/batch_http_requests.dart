library batch_http_requests;

import 'dart:convert';
import 'dart:developer';

import 'package:batch_http_requests/HttpTuple.dart';
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
      print("Returning API response from DB for URL: " + url);
      return response.response;
    }
    return await _getFromHttp(url);
  }

  Future<String> postResponse(String url, String data) async {
    HttpTuple response = await _postFromDB(url, data);
    if (response != null && response.status == 'SUCCESS') {
      print("Returning API response from DB for URL: " + url);
      return response.response;
    }
    return await _postFromHttp(url, data);
  }

  Future<String> _getFromHttp(String url) async {
    print("Making API call for URL: " + url);
    Response httpResponse = await _dio.get(url);
    var response = jsonEncode(httpResponse.data);
    database.updateRequest(url, "", response);
    return response;
  }

  Future<String> _postFromHttp(String url, String data) async {
    print("Making API call for URL: " + url);
    Response httpResponse = await _dio.post(url, data: data);
    var response = jsonEncode(httpResponse.data);
    database.updateRequest(url, data, response);
    return response;
  }

  Future<HttpTuple> _getFromDB(String url) async {
    HttpTuple response = await database.getResponseFromDB(url);
    if (response == null) {
      print("Received null response from DB for URL: " + url);
      database.insertRequest(new HttpTuple(url));
    }
    return response;
  }

  Future<HttpTuple> _postFromDB(String url, String data) async {
    HttpTuple response = await database.getResponseFromDBWithData(url, data);
    if (response == null) {
      print("Received null response from DB for URL: " + url);
      database.insertRequest(new HttpTuple.withUrlData(url, data));
    }
    return response;
  }
}
