import 'package:batch_http_requests/HttpTuple.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Utils.dart';

class RequestsDatabase {
  Future<Database> getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'batch_http_requests.db'),
        onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        "CREATE TABLE http_tuple(id INTEGER PRIMARY KEY, url TEXT, urlHash TEXT, data TEXT, dataHash TEXT, response TEXT, cacheDuration INTEGER)",
      );
    }, version: 1);
  }

  Future<void> insertRequest(HttpTuple httpTuple) async {
    final Database db = await getDatabase();

    await db.insert(
      'http_tuple',
      httpTuple.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRequest(String url, String data, String response) async {
    final Database db = await getDatabase();

    await db.rawUpdate(
        "UPDATE http_tuple SET response = ?, status = ? WHERE urlHash= ? AND dataHash= ?",
        [response, 'SUCCESS', Utils.hash(url), Utils.hash(data)]);
  }

  Future<List<HttpTuple>> getPendingRequests() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('http_tuple', where: "status='PENDING'");

    return List.generate(maps.length, (i) {
      return HttpTuple.withUrlDataAndCacheAndResponse(
        maps[0]['url'],
        maps[0]['data'],
        maps[0]['cacheDuration'],
        maps[0]['response'],
        maps[0]['status'],
      );
    });
  }

  Future<HttpTuple> getResponseFromDBWithData(String url, String data) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('http_tuple',
        where: "status!='PENDING' AND urlHash= ? AND dataHash = ?",
        whereArgs: [Utils.hash(url), Utils.hash(data)]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    return HttpTuple.withUrlDataAndCacheAndResponse(
      maps[0]['url'],
      maps[0]['data'],
      maps[0]['cacheDuration'],
      maps[0]['response'],
      maps[0]['status'],
    );
  }

  Future<HttpTuple> getResponseFromDB(String url) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('http_tuple',
        where: "status!='PENDING' AND urlHash='" + Utils.hash(url) + "'");
    if (maps == null || maps.length == 0) {
      return null;
    }

    return HttpTuple.withUrlDataAndCacheAndResponse(
      maps[0]['url'],
      maps[0]['data'],
      maps[0]['cacheDuration'],
      maps[0]['response'],
      maps[0]['status'],
    );
  }
}
