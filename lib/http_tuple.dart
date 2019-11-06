import 'package:batch_http_requests/Utils.dart';

class HttpTuple {
  int id;
  final String url;
  String urlHash;
  String data;
  String dataHash;
  int cacheDuration;
  String response;
  String status;
  int timestamp;

  HttpTuple(this.url) {
    this.id = 0;
    this.urlHash = Utils.hash(this.url);
    this.data = "";
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.cacheDuration = (5 * 60 * 1000); // 1 hour
    this.status = "PENDING";
    this.timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
  }

  HttpTuple.withUrlAndCache(this.url, this.cacheDuration) {
    this.id = 0;
    this.urlHash = Utils.hash(this.url);
    this.data = "";
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.status = "PENDING";
    this.timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
  }

  HttpTuple.withUrlData(this.url, this.data) {
    this.id = 0;
    this.urlHash = Utils.hash(this.url);
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.status = "PENDING";
    this.cacheDuration = (5 * 60 * 1000); // 1 hour
    this.timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
  }

  HttpTuple.withUrlDataAndCache(this.url, this.data, this.cacheDuration) {
    this.id = 0;
    this.urlHash = Utils.hash(this.url);
    this.dataHash = Utils.hash(this.data);
    this.response = "";
    this.status = "PENDING";
    this.timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
  }

  HttpTuple.withEverything(this.id, this.url, this.urlHash, this.data,
      this.dataHash,
      this.cacheDuration, this.response, this.status, this.timestamp);

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'urlHash': urlHash,
      'data': data,
      'dataHash': dataHash,
      'cacheDuration': cacheDuration,
      'response': response,
      'status': status,
      'timestamp': timestamp
    };
  }

  String toString() {
    String s = "url: $url\n"
        "urlHash: $urlHash\n"
        "data: $data\n"
        "dataHash: $dataHash\n"
        "cacheDuration: $cacheDuration\n"
        "response: $response\n"
        "status: $status\n"
        "timestamp: $timestamp\n";
    return s;
  }
}
