import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:macrotracker/models/day_data.dart';

//documntation : https://blog.logrocket.com/how-create-flutter-charts-with-charts-flutter/
class HistoryChart extends StatelessWidget {
  final List<DayData> data;

  const HistoryChart({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    List<charts.Series<DayData, String>> series = [
      charts.Series(
        id: "calories",
        data: data,
        domainFn: (DayData series, _) =>
            '${series.date.day}/${series.date.month}',
        measureFn: (DayData series, _) => series.kcal,
        colorFn: (DayData series, _) =>
            charts.MaterialPalette.green.shadeDefault, //recommended by autofill
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('History'), actions: [
          
        ],),

      body: Container(
        height: 700,
        padding: const EdgeInsets.all(25),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Calories per day",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Expanded(child: charts.BarChart(series, animate: true)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
