import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class CircleDiagram extends StatefulWidget {
  const CircleDiagram({super.key});

  @override
  State<CircleDiagram> createState() => _CircleDiagramState();
}

class _CircleDiagramState extends State<CircleDiagram> {
  late List<GPData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late int $diagval = 32;
  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SfCircularChart(
            tooltipBehavior: _tooltipBehavior,
            series: <CircularSeries>[RadialBarSeries<GPData, String>(
                dataSource: _chartData,
                xValueMapper: (GPData data,_) => data.continent,
                yValueMapper: (GPData data,_) => data.gdp,
                dataLabelSettings: const DataLabelSettings(isVisible: false),

                enableTooltip: true,
                maximumValue: 100
            ),]), // 4:13 min tutorial
      ),
    );
  }
  List<GPData> getChartData(){
    final List<GPData> chartData = [
      GPData('Oceania', $diagval),
    ];
    return chartData;
  }

}

class GPData {
  GPData(this.continent, this.gdp);
  final String continent;
  final int gdp;

}


