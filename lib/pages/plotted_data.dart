import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:workout_app/extensions/string_helper.dart';
import 'package:workout_app/pages/statistics.dart';

import '../reusable_widgets/containers.dart';
import '../reusable_widgets/loading.dart';
import 'generic.dart';

class XYPair {
  const XYPair({required this.x, required this.y});

  final DateTime x;
  final double y;
}

class PlottedDataPage extends StatefulWidget {
  const PlottedDataPage({super.key, required this.data, required this.title});

  final Future<List<HasFormatteableData>> data;
  final String title;

  @override
  State<PlottedDataPage> createState() => _PlottedDataPageState();
}

class _PlottedDataPageState extends State<PlottedDataPage> {
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();

    _trackballBehavior = TrackballBehavior(enable: true, tooltipDisplayMode: TrackballDisplayMode.groupAllPoints);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
    );
  }

  List<XYPair> randomData(int length) {
    var chartData = <XYPair>[];

    for (int i = length; i > 0; i--) {
      chartData.add(XYPair(x: DateTime.now().subtract(Duration(days: i * 7)), y: Random().nextInt(80 - 60) + 60));
    }

    return chartData;
  }

  DateTime discardTimestamp(DateTime time) {
    return time.copyWith(microsecond: 0, millisecond: 0, second: 0, minute: 0, hour: 0);
  }

  Widget createChart(List<HasFormatteableData> data, String title) {
    var dataSource = <XYPair>[];

    // Sort data by date and limit to the last 30
    data.sort((a, b) {
      var map = a.toFirestore();
      var map1 = b.toFirestore();
      return map[a.xAxisName].compareTo(map1[b.xAxisName]);
    });
    data = data.getRange(max(0, data.length - 30), data.length).toList();

    for (var element in data) {
      var map = element.toFirestore();
      var x = discardTimestamp(map[element.xAxisName]);
      var y = map[element.yAxisName];
      dataSource.add(XYPair(x: x, y: y));
    }

    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: data[0].xAxisName.capitalize()),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: data[0].yAxisName.capitalize()),
        labelFormat: data[0].yAxisFormat,
      ),
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      series: <ChartSeries>[
        LineSeries<XYPair, DateTime>(
          dataSource: dataSource,
          markerSettings: const MarkerSettings(isVisible: true),
          xValueMapper: (datum, index) => datum.x,
          yValueMapper: (datum, index) => datum.y,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var chart = FutureBuilder(
      future: widget.data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return createChart(snapshot.data!, widget.title);
        } else {
          return const LoadingFuture();
        }
      },
    );

    return GenericPage(
      scrollable: false,
      body: PaddedContainer(
        child: Column(
          children: [
            Expanded(
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}
