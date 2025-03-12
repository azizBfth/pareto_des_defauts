import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class DefectChart extends StatefulWidget {
  @override
  _DefectChartState createState() => _DefectChartState();
}

class _DefectChartState extends State<DefectChart> {
  final ApiService apiService = ApiService();
  Map<String, int> defectData = {};
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final List<Color> barColors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.cyan,Colors.yellow,Colors.teal,Colors.brown];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      _fetchData();
    }
  }

  void _fetchData() async {
    bool isAuthenticated = await apiService.authenticate("B.Aziz", "B.Aziz2022");
    if (isAuthenticated) {
      Map<String, int> data = await apiService.getAggregatedDefects(
        dateFormat.format(startDate),
        dateFormat.format(endDate),
      );
      setState(() {
        defectData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fréquence des Défauts")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateSelector("Début", startDate, true),
                _buildDateSelector("Fin", endDate, false),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: defectData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups: _generateBarGroups(),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                    getTitlesWidget: _getRotatedTitle,
                                    reservedSize: 80,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              gridData: FlGridData(show: true),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildLegend(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, bool isStartDate) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        InkWell(
          onTap: () => _selectDate(context, isStartDate),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(dateFormat.format(date), style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    List<BarChartGroupData> groups = [];
    int index = 0;
    defectData.forEach((name, count) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: barColors[index % barColors.length],
              width: 16,
            )
          ],
        ),
      );
      index++;
    });
    return groups;
  }

  Widget _getRotatedTitle(double value, TitleMeta meta) {
    final labels = defectData.keys.toList();
    if (value.toInt() >= labels.length) return Container();

    return Transform.rotate(
      angle: -0.5,
      child: Text(
        labels[value.toInt()],
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10,
      children: List.generate(defectData.length, (index) {
        final color = barColors[index % barColors.length];
        final category = defectData.keys.elementAt(index);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: color),
            SizedBox(width: 5),
            Text(category, style: TextStyle(fontSize: 14)),
          ],
        );
      }),
    );
  }
}
