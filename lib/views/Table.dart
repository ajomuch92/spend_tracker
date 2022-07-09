import 'package:flutter/material.dart';
import 'package:spend_tracker/models/FilterModel.dart';
import '../models/ResponseModel.dart';
import '../models/SpendModel.dart';

class TableView extends StatefulWidget {
  final FilterModel? filter;
  const TableView({Key? key, this.filter}) : super(key: key);

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  List<ChartResponseModel> chartDataList = [];

  @override
  initState() {
    super.initState();
    if (mounted) {
      loadDataList();
      setListener();
    }
  }

  Future<void> loadDataList() async{
    List<ChartResponseModel> list = await SpendModel.getChartDataListLastMonth(filter: widget.filter);
    list.sort((a, b) => a.amount!.compareTo(b.amount!));
    setState(() {
      chartDataList = list;
    });
  }

  void setListener() {
    if (widget.filter != null) {
      widget.filter!.addListener(() {
        if (mounted) loadDataList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        color: Colors.white,
        child: Center(
          child: DataTable(
            border: TableBorder.all(  
              color: Colors.black,  
              style: BorderStyle.solid,  
              width: 2
            ),
            columns: const [
              DataColumn(
                label: Text('Category'),
              ),
              DataColumn(
                label: Text('Amount'),
              )
            ],
            rows: getTableRows(),
          ),
        ),
      ),
    );
  }

  List<DataRow> getTableRows() {
    List<DataRow> rows = [];
    for (var element in chartDataList) {
      rows.add(DataRow(cells: [
        DataCell(Text(element.name!)),
        DataCell(Text('L ${element.amount!.toStringAsFixed(2)}')),
      ]));
    }
    return rows;
  }
}