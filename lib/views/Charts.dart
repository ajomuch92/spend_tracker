import 'package:flutter/material.dart';
import 'package:flutter_is_dark_color_hsp/flutter_is_dark_color_hsp.dart';
import 'package:pie_chart/pie_chart.dart';
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
    if (mounted) {
      setState(() {
        chartDataList = list;
      });
    }
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
    return PieChart(
      dataMap: getDataMap(),
      animationDuration: const Duration(milliseconds: 500),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 2,
      colorList: chartDataList.map((e) => Color(e.color!)).toList(),
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 32,
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.bottom,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 2,
      ),
    );
  }

  Map<String, double> getDataMap() {
    Map<String, double> result = {};
    for (var element in chartDataList) { 
      result[element.name!] = element.amount!;
    }
    return result;
  }
}
