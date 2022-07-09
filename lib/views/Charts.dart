import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_is_dark_color_hsp/flutter_is_dark_color_hsp.dart';
import 'package:spend_tracker/models/FilterModel.dart';
import 'package:spend_tracker/models/SpendModel.dart';

import '../models/ResponseModel.dart';

class Chart extends StatefulWidget {
  final FilterModel? filter;
  const Chart({Key? key, this.filter}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
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
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        color: Colors.white,
        child: Center(
          child: chartDataList.isEmpty ? const Text('No data') : getChartDataWidget(),
        ),
      ),
    );
  }

  Widget getChartDataWidget() {
    double greatTotal = chartDataList.map((e) => e.amount??0).reduce((value, element) => value + element);
    return PieChart(
      PieChartData(
          sections: chartDataList.map((e) {
            Color color = Color(e.color!);
            String percent = (e.amount! / greatTotal * 100).toStringAsFixed(2);
            return PieChartSectionData(
              color: color,
              value: e.amount!,
              title: '${e.name!}($percent%)',
              radius: 100.0,
              titleStyle: TextStyle(
                color: isDarkHsp(color)! ? Colors.white : Colors.black,

              ),
            );
          }).toList()
      ),
      swapAnimationDuration: const Duration(milliseconds: 150),
      swapAnimationCurve: Curves.linear,
    );
  }
}
