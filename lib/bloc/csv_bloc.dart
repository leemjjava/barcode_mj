import 'package:barcode_mj/bloc/product_bloc.dart';
import 'package:barcode_mj/db/db_helper.dart';
import 'package:flutter/services.dart';

const icCategory01 = 'category01';
const icCategory02 = 'category02';
const icName = 'name';
const icBarcode = 'barcode';
const icPrice = 'price';
const icTexType = 'texType';
const icBayPrice = 'bay_price';
const icCount = 'count';
const icDate = 'date';

class CsvBloc{
  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> loadCSV() async{
    String data = await loadAsset('assets/sale_csv_counting.csv');

    String csvStr = data;
    final itemList = csvStr.split('\n');
    List<Map<String,String>> productList = [];
    for(String item in itemList){
      final columns = item.split(',');

      final product = {
        icCategory01: columns[0].trim(),
        icCategory02: columns[1].trim(),
        icBarcode : columns[2].trim(),
        icName: columns[3].trim(),
        icPrice : columns[4].trim(),
        icBayPrice: columns[5].trim(),
        icTexType: columns[6].trim(),
        icCount: columns[7].trim(),
      };

      productList.add(product);
    }

    print('count : ${productList.length}');
    int insertCount = await DBHelper().insertProductAll(productList);
    print('insert Count : $insertCount');
  }
}