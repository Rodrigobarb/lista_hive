import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';

void exportToJSON(Box<dynamic> box, String filePath) async {
  List<Map<String, dynamic>> jsonData = [];

  for (int i = 0; i < box.length; i++) {
    var item = box.getAt(i)!;
    jsonData.add(item.toJson());
  }

  File file = File(filePath);
  await file.writeAsString(jsonEncode(jsonData));

  print('Dados exportados para JSON com sucesso.');
}
