import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  // Database? db;
  Future<Database> createDatabase() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    // open the database
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Test (id INTEGER PRIMARY KEY, language_1 TEXT, text_controller TEXT,language_2 TEXT,text_translated TEXT,isFav TEXT)');
        });
    // print(pat);
    return database;
  }

  // Future<int> insertDataItem(String name,int quan,String unit,int cal) async {
  //   if (db == null) {
  //     throw "bd is not initiated, initiate using [init(db)] function";
  //   }
  //
  //   var raw = await db!.rawInsert("INSERT INTO mywords (name,quan,unit,cal) VALUES ('$name',$quan,'$unit',$cal)");
  //   // var raw = await db.insert('fav', FavModel.toJson());]
  //   print("raw------${raw}");
  //
  //   return raw;/**/
  //
  // }
}