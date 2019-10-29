import 'package:batch_http_requests/http_tuple.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Utils.dart';

class RequestsDatabase {
  Future<Database> getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'batch_http_requests.db'),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE http_tuple(id INTEGER PRIMARY KEY, url TEXT, urlHash TEXT, data TEXT, dataHash TEXT, response TEXT, cacheDuration INTEGER, status TEXT, timestamp INTEGER)",
      );
    }, version: 1);
  }

  Future<int> insertRequest(HttpTuple httpTuple) async {
    final Database db = await getDatabase();

    return await db.insert(
      'http_tuple',
      httpTuple.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateRequest(String url, String response) async {
    final Database db = await getDatabase();

    var hash = Utils.hash(url);
    return await db.rawUpdate(
        "UPDATE http_tuple SET response = ?, status = ?, timestamp = ? WHERE urlHash= ?",
        [response, 'SUCCESS', getTimeStamp(), hash]);
  }

  int getTimeStamp() {
    return DateTime
        .now()
        .millisecondsSinceEpoch;
  }

  Future<int> updateRequestWithData(String url, String data,
      String response) async {
    final Database db = await getDatabase();

    var urlHash = Utils.hash(url);
    var dataHash = Utils.hash(data);
    return await db.rawUpdate(
        "UPDATE http_tuple SET response = ?, status = ?, timestamp = ? WHERE urlHash= ? AND dataHash= ?",
        [response, 'SUCCESS', getTimeStamp(), urlHash, dataHash]);
  }

  Future<List<HttpTuple>> getPendingRequests() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('http_tuple', where: "status='PENDING'");
    return List.generate(maps.length, (i) => getHttpTupleFromMap(maps[i]));
  }

  Future<HttpTuple> getResponseFromDBWithData(String url, String data) async {
    final Database db = await getDatabase();
    var urlHash = Utils.hash(url);
    var dataHash = Utils.hash(data);
    final List<Map<String, dynamic>> maps = await db.query('http_tuple',
        where: "status!='PENDING' AND urlHash= ? AND dataHash = ?",
        whereArgs: [urlHash, dataHash]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    HttpTuple tuple = getHttpTupleFromMap(maps[0]);

    if (getTimeStamp() > tuple.timestamp + tuple.cacheDuration) {
      deleteFromDBWithData(url, data);
      return null;
    }
    return tuple;
  }

  Future<HttpTuple> getResponseFromDB(String url) async {
    final Database db = await getDatabase();
    var urlHash = Utils.hash(url);
    final List<Map<String, dynamic>> maps = await db.query('http_tuple',
        where: "status!='PENDING' AND urlHash= ?", whereArgs: [urlHash]);
    if (maps == null || maps.length == 0) {
      return null;
    }

    HttpTuple tuple = getHttpTupleFromMap(maps[0]);

    if (getTimeStamp() > tuple.timestamp + tuple.cacheDuration) {
      deleteFromDB(url);
      return null;
    }
    return tuple;
  }

  Future<int> deleteFromDB(String url) async {
    final Database db = await getDatabase();
    var urlHash = Utils.hash(url);
    return await db.delete('http_tuple',
        where: "urlHash= ?", whereArgs: [urlHash]);
  }

  Future<int> deleteFromDBWithData(String url, String data) async {
    final Database db = await getDatabase();
    var urlHash = Utils.hash(url);
    var dataHash = Utils.hash(data);
    return await db.delete('http_tuple',
        where: "urlHash= ? AND dataHash= ? ", whereArgs: [urlHash, dataHash]);
  }

  HttpTuple getHttpTupleFromMap(Map<String, dynamic> map) {
    return HttpTuple.withEverything(
      map['id'],
      map['url'],
      map['urlHash'],
      map['data'],
      map['dataHash'],
      map['cacheDuration'],
      map['response'],
      map['status'],
      map['timestamp'],
    );
  }
}
