import 'package:flutter/material.dart';

class FilterModel extends ChangeNotifier{
  DateTimeRange? dateRange;
  int? idCategory;

  FilterModel({this.dateRange, this.idCategory});

  @override
  bool operator == (other) => other is FilterModel && (other.idCategory == idCategory || other.dateRange == dateRange);

  void notify() {
    notifyListeners();
  }

  factory FilterModel.fromCustomJson(Map<String, dynamic> json) {
    return FilterModel(
      dateRange: json['dateRange'],
      idCategory: json['idCategory'],
    );
  }

  @override
  int get hashCode => super.hashCode;

}