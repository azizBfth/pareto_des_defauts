import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class DefectPieChart extends StatefulWidget {
  @override
  _DefectPieChartState createState() => _DefectPieChartState();
}

class _DefectPieChartState extends State<DefectPieChart> {
  final ApiService apiService = ApiService();
  Map<String, int> categoryData = {};
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

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
      Map<String, int> data = await apiService.getDefectCategories(
        dateFormat.format(startDate),
        dateFormat.format(endDate),
      );
      setState(() {
        categoryData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Répartition des Catégories de Défauts")),
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
              child: categoryData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : PieChart(
                      PieChartData(
                        sections: _generatePieSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: _buildLegend(),
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

  List<PieChartSectionData> _generatePieSections() {
    final colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.cyan,Colors.yellow,Colors.teal,Colors.brown
    ];
    int index = 0;

    return categoryData.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: "${entry.value}",
        radius: 120,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.cyan
    ];
    int index = 0;

    return categoryData.keys.map((category) {
      final color = colors[index % colors.length];
      index++;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          SizedBox(width: 5),
          Text(category, style: TextStyle(fontSize: 14)),
        ],
      );
    }).toList();
  }
}
