import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spend_tracker/data/database.dart';
import 'package:spend_tracker/models/ResponseModel.dart';
import 'package:sqflite/sqflite.dart';

class CategoryModel {
  int? id, color;
  String? name, icon;
  Database? _db;

  CategoryModel({this.id, this.name, this.icon, this.color});

  factory CategoryModel.fromCustomJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'],
      icon: json['icon'],
      color: int.tryParse(json['color']?.toString() ?? ''),
    );
  }

  Future<void> save() async {
    _db ??= await getDatabase();
    int lastInsertId = await _db!.rawInsert(
        'INSERT INTO categories(name, icon, color) VALUES(?, ?, ?)',
        [name, icon, color]);
    id = lastInsertId;
  }

  @override
  String toString() {
    return name!;
  }

  Future<bool> update() async {
    _db ??= await getDatabase();
    List<Map<String, dynamic>> result = await _db!.query('categories', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      CategoryModel oldValue = CategoryModel.fromCustomJson(result[0]);
      oldValue.name = name;
      oldValue.icon = icon;
      oldValue.color = color;
      int updated = await _db!.rawUpdate(
          'UPDATE categories SET name = ?, icon = ?, color = ? WHERE id = ?',
          [oldValue.name, oldValue.icon, oldValue.color, id]);
      return updated > 0;
    }
    return false;
  }

  Future<bool> delete() async {
    _db ??= await getDatabase();
    int? total = Sqflite.firstIntValue(await _db!.rawQuery('SELECT COUNT(*) FROM spends WHERE idCategory = $id'));
    if (total! > 0) return false;
    int result = await _db!.rawDelete('DELETE FROM categories WHERE id = ?', [id]);
    return result > 0;
  }

  static Future<ResponseModel> getList({int offset = 0, int limit = 10}) async {
    List<CategoryModel> list = [];
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query('categories', limit: limit, offset: offset);
    int? total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories'));
    for (var element in result) {
      list.add(CategoryModel.fromCustomJson(element));
    }
    return ResponseModel(total: total??0, limit: limit, items: list, offset: offset);
  }

  static Future<CategoryModel?> getById(int id) async {
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return CategoryModel.fromCustomJson(result[0]);
    }
    return null;
  }
}