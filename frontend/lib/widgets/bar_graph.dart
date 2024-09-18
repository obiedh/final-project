import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyBarGraph extends StatelessWidget {
  final List<double> summary;
  final List<String> titles;
  final Function(int)? onBarTap;

  const MyBarGraph({
    Key? key,
    required this.summary,
    required this.titles,
    this.onBarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: summary.reduce((a, b) => a > b ? a : b) + 10,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  getBottomTitles(value, meta, titles),
              reservedSize: 60,
            ),
          ),
        ),
        barGroups: summary
            .asMap()
            .entries
            .map(
              (data) => BarChartGroupData(
                x: data.key,
                barRods: [
                  BarChartRodData(
                    toY: data.value,
                    color: const Color.fromARGB(255, 131, 57, 0),
                    width: 15,
                  ),
                ],
                showingTooltipIndicators: [],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (onBarTap != null &&
                event.isInterestedForInteractions &&
                barTouchResponse != null &&
                barTouchResponse.spot != null) {
              onBarTap!(barTouchResponse.spot!.touchedBarGroupIndex);
            }
          },
          mouseCursorResolver: (FlTouchEvent event, response) {
            return response == null || response.spot == null
                ? MouseCursor.defer
                : SystemMouseCursors.click;
          },
        ),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta, List<String> titles) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  Widget text = Text(
    titles[value.toInt()],
    style: style,
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 10,
    child: text,
  );
}
