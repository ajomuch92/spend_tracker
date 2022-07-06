class ResponseModel {
  int total;
  int offset;
  int limit;
  List<dynamic> items;

  ResponseModel({required this.total, required this.limit, required this.items, required this.offset});
}

class ChartResponseModel {
  String? name;
  double? amount;
  int? color;

  ChartResponseModel({this.name, this.amount, this.color});

  factory ChartResponseModel.fromCustomJson(Map<String, dynamic> json) {
    return ChartResponseModel(
      name: json['name'],
      amount: double.tryParse(json['amount']?.toString() ?? '0'),
      color: int.tryParse(json['color']?.toString() ?? '0')
    );
  }
}