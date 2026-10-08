import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HorizontalArabicBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: RotatedBox(
          quarterTurns: 1, // Rotates the chart to make bars horizontal
          child: AspectRatio(
            aspectRatio: 1.2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 25,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, _) {
                        const labels = [
                          'Test',
                          'My',
                          'Track',
                          'Item',
                          'Test',
                          'Summary',
                          'Voice'
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < labels.length) {
                          return RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              labels[value.toInt()],
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, _) => RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildGroup(0, 15, 10),
                  _buildGroup(1, 6, 3),
                  _buildGroup(2, 12, 7),
                  _buildGroup(3, 7, 4),
                  _buildGroup(4, 20, 15),
                  _buildGroup(5, 18, 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildGroup(int x, double full, double fill) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: full,
          width: 22,
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(10),
          rodStackItems: [
            BarChartRodStackItem(0, fill, Colors.indigo),
          ],
        ),
      ],
    );
  }
}
