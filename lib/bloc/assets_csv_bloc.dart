import 'package:barcode_mj/db/db_helper.dart';
import 'package:flutter/services.dart';

const icCategory01 = 'category01';
const icCategory02 = 'category02';
const icName = 'name';
const icBarcode = 'barcode';
const icPrice = 'price';
const icTexType = 'texType';
const icBayPrice = 'bay_price';

class AssetsCsvBloc{
  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> loadCSV() async{
    String data = await loadAsset('assets/sale_csv_final.csv');

    String csvStr = data;
    final itemList = csvStr.split('\n');
    List<Map<String,String>> productList = [];
    for(String item in itemList){
      final columns = item.split(',');

      final product = {
        icCategory01: columns[0],
        icCategory02: columns[1],
        icBarcode : columns[2],
        icName: columns[3],
        icPrice : columns[4],
        icBayPrice: columns[5],
        icTexType: columns[6],
      };

      productList.add(product);
    }

    print('count : ${productList.length}');
    int insertCount = await DBHelper().insertProductAll(productList);
    print('insert Count : $insertCount');
    final documents = await DBHelper().selectAllProduct();
    print('documents.length : ${documents.length}');
  }
}