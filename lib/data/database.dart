import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDatabase() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'spend_tracker.db');

  // await deleteDatabase(path);

  Database database = await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async {
      await db.execute(
          '''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY,
              name TEXT,
              icon TEXT,
              color INTEGER
            );
          '''
      );
      await db.execute(
          '''
            CREATE TABLE spends (
              id INTEGER PRIMARY KEY,
              description TEXT,
              amount INTEGER,
              date INTEGER,
              idCategory INTEGER,
              FOREIGN KEY (idCategory) REFERENCES categories(id)
            );
          '''
      );
    }
  );

  return database;
}