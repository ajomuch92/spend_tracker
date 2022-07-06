
import 'package:spend_tracker/data/database.dart';
import 'package:spend_tracker/models/CategoryModel.dart';
import 'package:spend_tracker/models/ResponseModel.dart';
import 'package:sqflite/sqflite.dart';

class SpendModel {
  int? id, idCategory;
  double? amount;
  String? description;
  DateTime? date;
  late CategoryModel? categoryModel;
  Database? _db;

  SpendModel({this.id, this.amount, this.description, this.date, this.idCategory});

  factory SpendModel.fromCustomJson(Map<String, dynamic> json) {
    return SpendModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      description: json['description'],
      idCategory: int.tryParse(json['idCategory']?.toString() ?? ''),
      amount: double.tryParse(json['amount']?.toString() ?? ''),
      date: DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['date'].toString()) ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Future<void> save() async{
    _db ??= await getDatabase();
    int lastInsertId = await _db!.rawInsert(
        'INSERT INTO spends(description, amount, date, idCategory) VALUES(?, ?, ?, ?)',
        [description, amount, date!.millisecondsSinceEpoch, idCategory]);
    id = lastInsertId;
  }

  Future<bool> update() async {
    _db ??= await getDatabase();
    List<Map<String, dynamic>> result = await _db!.query('spends', where: '"id" = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      SpendModel oldValue = SpendModel.fromCustomJson(result[0]);
      oldValue.description = description;
      oldValue.amount = amount;
      oldValue.idCategory = idCategory;
      oldValue.date = date;
      int updated = await _db!.rawUpdate(
          'UPDATE spends SET description = ?, amount = ?, date = ?, idCategory = ? WHERE id = ?',
          [oldValue.description, oldValue.amount, oldValue.date!.millisecondsSinceEpoch, id]);
      return updated > 0;
    }
    return false;
  }

  Future<bool> delete() async {
    _db ??= await getDatabase();
    int result = await _db!.rawDelete('DELETE FROM spends WHERE id = ?', [id]);
    return result > 0;
  }

  static Future<ResponseModel> getList({int offset = 0, int limit = 10}) async {
    List<SpendModel> list = [];
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query('spends', limit: limit, offset: offset, orderBy: 'date ASC');
    int? total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM spends'));
    for (var element in result) {
      SpendModel spendModel = SpendModel.fromCustomJson(element);
      spendModel.categoryModel = await CategoryModel.getById(spendModel.idCategory!);
      list.add(spendModel);
    }
    return ResponseModel(total: total??0, limit: limit, items: list, offset: offset);
  }

  static Future<SpendModel?> getById(int id) async {
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query('spends', where: '"id" = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return SpendModel.fromCustomJson(result[0]);
    }
    return null;
  }

  static Future<double> getTotalLastMonth() async {
    try {
      double total = 0.0;
      Database db = await getDatabase();
      DateTime date = DateTime.now();
      date = DateTime(date.year, date.month, 1);
      List<Map<String, dynamic>> result = await db.rawQuery('SELECT SUM(amount) sum FROM spends WHERE date >= ${date.millisecondsSinceEpoch}');
      if (result.isNotEmpty) {
        total = double.tryParse(result[0]['sum']?.toString() ?? '0') ?? 0;
      }
      return total;
    } catch (ex) {
      return 0;
    }
  }

  static Future<List<ChartResponseModel>> getChartDataListLastMonth() async {
    try {
      Database db = await getDatabase();
      DateTime date = DateTime.now();
      date = DateTime(date.year, date.month, 1);
      List<ChartResponseModel> list = [];
      String sql = '''
        SELECT B.name, B.color, SUM(A.amount) amount FROM spends A
        INNER JOIN categories B
        ON A.idCategory = B.id
        WHERE A.date >= ${date.millisecondsSinceEpoch}
        GROUP BY B.name, B.color
      ''';
      List<Map<String, dynamic>> result = await db.rawQuery(sql);
      if (result.isNotEmpty) {
        for (var element in result) {
          list.add(ChartResponseModel.fromCustomJson(element));
        }
      }
      return list;
    } catch (ex) {
      return [];
    }
  }
}