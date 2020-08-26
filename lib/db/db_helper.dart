import 'dart:io';
import 'package:barcode_mj/bloc/assets_csv_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'quickLawDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {

          await db.execute(productTableCreate);

        },
        onUpgrade: (db, oldVersion, newVersion) async{

        }
    );
  }

  static final String productTable = 'product';
  static final String product = '_id';

  static final String productTableCreate = '''
          CREATE TABLE $productTable(
            $product INTEGER PRIMARY KEY,
            $icBarcode TEXT UNIQUE,
            $icCategory01 TEXT,
            $icCategory02 TEXT,
            $icName TEXT,
            $icPrice TEXT,
            $icTexType TEXT,
            $icBayPrice TEXT
          )
        ''';

  Future<int> insertProductAll(List<Map<String,String>> productList) async {
    final db = await database;

    return await db.transaction<int>((txn)async {
      int count = -1;
      productDeleteAll(transaction: txn);
      for(Map item in productList){
        count = await insertProduct(item: item, transaction: txn);
      }

      return count;
    });
  }

  Future<int> insertProduct({
    Map<String, String> item,
    Transaction transaction,
  }) async {

    String sql = '''INSERT OR REPLACE INTO $productTable(
    $icCategory01,
    $icCategory02,
    $icName,
    $icBarcode,
    $icPrice,
    $icTexType,
    $icBayPrice
    )VALUES(?,?,?,?,?,?,?)''';

    String name = item[icName].replaceAll(',', ' ');
    String price = item[icPrice].replaceAll(',', '');
    String isByPrice = item[icBayPrice].replaceAll(',', '');

    List<dynamic> arguments = [
      item[icCategory01] ?? '미분류',
      item[icCategory02] ?? '',
      name,
      item[icBarcode],
      price,
      item[icTexType] ?? '포함',
      isByPrice ?? '',
    ];

    if(transaction != null) return transaction.rawInsert(sql,arguments);

    final db = await database;
    return await db.rawInsert(sql,arguments);
  }

  Future<List<Map>> selectAllProduct() async{
    final db = await database;
    List<Map> res = await db.query(
      productTable,
      columns: [icCategory01, icCategory02, icName, icBarcode, icPrice, icTexType, icBayPrice],
    );

    return res;
  }

  //Delete All
  productDeleteAll({Transaction transaction}) async {
    if(transaction != null) return transaction.delete(productTable);

    final db = await database;
    return db.delete(productTable);
  }

}
