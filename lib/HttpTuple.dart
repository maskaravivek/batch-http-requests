import 'package:batch_http_requests/Utils.dart';

class HttpTuple {
  final String url;
  String urlHash;
  String data;
  String dataHash;
  int cacheDuration;
  String response;
  String status;

  HttpTuple(this.url) {
    this.urlHash = Utils.hash(this.url);
    this.data = "";
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.cacheDuration = (60 * 60); // 1 hour
    this.status = "PENDING";
  }

  HttpTuple.withUrlData(this.url, this.data) {
    this.urlHash = Utils.hash(this.url);
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.status = "PENDING";
    this.cacheDuration = (60 * 60); // 1 hour
  }

  HttpTuple.withUrlDataAndCache(this.url, this.data, this.cacheDuration) {
    this.urlHash = Utils.hash(this.url);
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.status = "PENDING";
  }

  HttpTuple.withUrlDataAndCacheAndResponse(this.url, this.data, this.cacheDuration, this.response, this.status) {
    this.urlHash = Utils.hash(this.url);
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.status = "PENDING";
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'urlHash': urlHash,
      'data': data,
      'dataHash': dataHash,
      'cacheDuration': cacheDuration,
      'response': response,
      'status': status
    };
  }

  String toString() {
    String s = "url: $url"
        "urlHash: $urlHash"
        "data: $data"
        "dataHash: $dataHash"
        "cacheDuration: $cacheDuration"
        "response: $response"
        "status: $status";
    return s;
  }
}
