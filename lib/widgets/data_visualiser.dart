import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as chart;

class GraphData {
  double value;
  int index;
}

Widget dataVisualiser(
    List<GraphData> _data, String xAxisLabel, String yAxisLabel, int win) {
  var min, max;
  for (int i = 0; i < _data.length; i++) {
    if (i == 0) {
      min = _data[i].value;
      max = _data[i].value;
    }
    if (_data[i].value > max) max = _data[i].value;
    if (_data[i].value < min) min = _data[i].value;
  }
  List<chart.Series<GraphData, int>> lineGraphData = [];
  lineGraphData.add(chart.Series(
    colorFn: (__, _) => chart.ColorUtil.fromDartColor(Colors.blue),
    id: 'Sensor Values',
    data: _data,
    domainFn: (GraphData point, _) => point.index,
    measureFn: (GraphData point, _) => point.value,
  ));

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
    child: new chart.LineChart(
      lineGraphData,
      animate: false,
      primaryMeasureAxis: new chart.NumericAxisSpec(
        viewport: new chart.NumericExtents(min - win, max + win),
      ),
      behaviors: [
        new chart.PanAndZoomBehavior(),
        new chart.ChartTitle(xAxisLabel,
            behaviorPosition: chart.BehaviorPosition.bottom,
            titleOutsideJustification:
                chart.OutsideJustification.middleDrawArea),
        new chart.ChartTitle(yAxisLabel,
            behaviorPosition: chart.BehaviorPosition.start,
            titleOutsideJustification:
                chart.OutsideJustification.middleDrawArea)
      ],
    ),
  );
}
