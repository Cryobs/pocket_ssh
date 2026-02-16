import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CircleDiagram extends StatefulWidget {
  final int diagval;
  final String label;
  final String title;
  final String? alternativeLabel;

  const CircleDiagram({
    super.key,
    required this.diagval,
    required this.label,
    required this.title,
    this.alternativeLabel,
  });

  @override
  State<CircleDiagram> createState() => _CircleDiagramState();
}

class _CircleDiagramState extends State<CircleDiagram> {
  late List<GPData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  bool _showAlternative = false;

  @override
  void initState() {
    super.initState();
    _chartData = _getChartData();
    _tooltipBehavior = TooltipBehavior(enable: false);
  }

  @override
  void didUpdateWidget(covariant CircleDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diagval != widget.diagval) {
      _chartData = _getChartData();
    }
  }

  void _toggleLabel() {
    if (widget.alternativeLabel != null) {
      setState(() {
        _showAlternative = !_showAlternative;
      });
    }
  }

  double _getFontSize(String text, double baseSize) {
    final len = text.length;
    if (len <= 4) return baseSize * 0.9;     // "100%"
    if (len <= 6) return baseSize * 0.65;    // "123 GB"
    if (len <= 8) return baseSize * 0.55;    // "1234 GB"
    return baseSize * 0.45;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final size = (availableWidth < availableHeight
            ? availableWidth
            : availableHeight).clamp(60.0, 120.0);

        final currentLabel = _showAlternative && widget.alternativeLabel != null
            ? widget.alternativeLabel!
            : widget.label;

        final labelFontSize = (size * 0.2).clamp(10.0, 16.0);

        return SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SfCircularChart(
                      backgroundColor: Colors.transparent,
                      palette: <Color>[getColor()],
                      tooltipBehavior: _tooltipBehavior,
                      margin: EdgeInsets.zero,

                      series: [
                        RadialBarSeries<GPData, String>(
                          dataSource: _chartData,
                          xValueMapper: (GPData data, _) => data.label,
                          yValueMapper: (GPData data, _) => data.gdp,
                          maximumValue: 100,
                          radius: '100%',
                          innerRadius: '80%',
                          cornerStyle: widget.diagval >= 100 ? CornerStyle.bothFlat : CornerStyle.bothCurve,
                          trackColor: getColor(),
                          trackOpacity: 0.3,
                        ),
                      ],
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleLabel,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: size * 0.7,
                              ),
                              child: Text(
                                currentLabel,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: _getFontSize(currentLabel, labelFontSize),
                                  fontWeight: FontWeight.bold,
                                  color: getColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<GPData> _getChartData() {
    return [GPData('Value', widget.diagval)];
  }

  Color getColor() {
    if (widget.diagval < 50) return const Color(0xFF22C55E);
    if (widget.diagval < 90) return const Color(0xFFE5A50A);
    return const Color(0xFFE9220C);
  }
}

class GPData {
  GPData(this.label, this.gdp);
  final String label;
  final int gdp;
}