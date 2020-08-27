import 'dart:io';
import 'package:barcode_mj/bloc/assets_csv_bloc.dart';
import 'package:barcode_mj/util/resource.dart';
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
        version: 3,
        onCreate: (db, version) async {

          await db.execute(productTableCreate);

        },
        onUpgrade: (db, oldVersion, newVersion) async{
          if(oldVersion < 2) await db.execute("ALTER TABLE $productTable ADD COLUMN $icDate TEXT;");
          if(oldVersion < 3) await db.execute("ALTER TABLE $productTable ADD COLUMN $icCount TEXT;");
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
            $icBayPrice TEXT,
            $icCount TEXT,
            $icDate INTEGER
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
    $icBayPrice,
    $icCount,
    $icDate
    )VALUES(?,?,?,?,?,?,?,?,?)''';

    String name = item[icName].replaceAll(',', ' ');
    String price = item[icPrice].replaceAll(',', '');
    String isByPrice = item[icBayPrice].replaceAll(',', '');
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    List<dynamic> arguments = [
      item[icCategory01] ?? '미분류',
      item[icCategory02] ?? '',
      name,
      item[icBarcode],
      price,
      item[icTexType] ?? '포함',
      isByPrice ?? '',
      item[icCount] ?? '',
      timeStamp
    ];

    if(transaction != null) return transaction.rawInsert(sql,arguments);

    final db = await database;
    return await db.rawInsert(sql,arguments);
  }

  Future<int> insertServerProductAll(List<Map<String, dynamic>> documentList) async {
    final db = await database;

    return await db.transaction<int>((txn)async {
      int count = -1;
      productDeleteAll(transaction: txn);
      for(final document in documentList){
        count = await insertServerProduct(item: document, transaction: txn);
      }

      return count;
    });
  }

  Future<int> insertServerProduct({
    Map<String, dynamic> item,
    Transaction transaction,
  }) async {

    String sql = '''INSERT OR REPLACE INTO $productTable(
    $icCategory01,
    $icCategory02,
    $icName,
    $icBarcode,
    $icPrice,
    $icTexType,
    $icBayPrice,
    $icCount,
    $icDate
    )VALUES(?,?,?,?,?,?,?,?,?)''';

    String name = item[fnName].replaceAll(',', ' ');
    String price = item[fnPrice].replaceAll(',', '');
    String barcode = item[fnBarcode];
    String count = item[fnCount] ?? '';
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    List<dynamic> arguments = [
      '미분류', '', name, barcode, price, '포함', '', count,timeStamp
    ];

    if(transaction != null) return transaction.rawInsert(sql,arguments);

    final db = await database;
    return await db.rawInsert(sql,arguments);
  }

  Future<List<Map>> selectAllProduct() async{
    final db = await database;
    List<Map> res = await db.query(
      productTable,
      columns: [
        icCategory01,
        icCategory02,
        icName,
        icBarcode,
        icPrice,
        icTexType,
        icBayPrice,
        icCount,
        icDate
      ],
      orderBy: '$icDate DESC'
    );

    return res;
  }

  Future<List<Map>> selectByBarcode(String barcode) async{
    final db = await database;
    List<Map> res = await db.query(
        productTable,
        columns: [
          icCategory01,
          icCategory02,
          icName,
          icBarcode,
          icPrice,
          icTexType,
          icBayPrice,
          icCount,
          icDate
        ],
        where: '$icBarcode = ?',
        whereArgs: [barcode]
    );

    return res;
  }


  Future<int> updateCategory(Map<String, dynamic> item, String category) async{
    final db = await database;

    String barcode = item[icBarcode];
    return await db.update(
        productTable,
        {icCategory01 : category},
        where: '$icBarcode = ?',
        whereArgs: [barcode],
    );
  }

  Future<int> selectProductCount() async{
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $productTable'));
  }

  //Delete All
  productDeleteAll({Transaction transaction}) async {
    if(transaction != null) return transaction.delete(productTable);

    final db = await database;
    return db.delete(productTable);
  }

}
