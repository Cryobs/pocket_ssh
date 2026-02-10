import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class CircleDiagram extends StatefulWidget {
  final int diagval;
  final String label;
  final String title;
  const CircleDiagram({
    super.key,
    required this.diagval,
    required this.label,
    required this.title
  });

  @override
  State<CircleDiagram> createState() => _CircleDiagramState();
}

class _CircleDiagramState extends State<CircleDiagram> {
  late List<GPData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CircleDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.diagval != widget.diagval) {
      setState(() {
        _chartData = getChartData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double size = constraints.biggest.shortestSide;
            final double fontSize = size * 0.12;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                SizedBox(
                  width: size,
                  height: size,
                  child: SfCircularChart(
                    backgroundColor: Colors.transparent,
                    palette: <Color>[getColor()],
                    tooltipBehavior: _tooltipBehavior,

                    annotations: [
                      CircularChartAnnotation(
                        widget: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: getColor(),
                          ),
                        ),
                      ),
                    ],

                    series: [
                      RadialBarSeries<GPData, String>(
                        dataSource: _chartData,
                        xValueMapper: (GPData data, _) => data.label,
                        yValueMapper: (GPData data, _) => data.gdp,
                        maximumValue: 100,
                        radius: '90%',
                        innerRadius: '75%',
                        cornerStyle: CornerStyle.bothCurve,
                        trackColor: getColor(),
                        trackOpacity: 0.3,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }




  List<GPData> getChartData(){
    final List<GPData> chartData = [
      GPData('Oceania', widget.diagval),
    ];
    return chartData;
  }
  
  Color getColor() {
    if (widget.diagval < 50) {
      return const Color(0xFF22C55E);
    } else if (widget.diagval < 90) {
      return const Color(0xFFE5A50A);
    } else {
      return const Color(0xFFE9220C);
    }
  }

}

class GPData {
  GPData(this.label, this.gdp);
  final String label;
  final int gdp;

}


