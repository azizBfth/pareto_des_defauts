import 'package:flutter/material.dart';
import 'package:pareto_des_defauts/DefectChart.dart';
import 'package:pareto_des_defauts/DefectPieChart.dart';


class DefectDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard des Défauts")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DefectChart()));
              },
              child: Text("Histogramme des Défauts"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DefectPieChart()));
              },
              child: Text("Catégories des defauts"),
            ),
          ],
        ),
      ),
    );
  }
}
