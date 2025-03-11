import 'package:flutter/material.dart';
import 'package:pareto_des_defauts/DefectDashboard.dart';
import 'api_service.dart';

void main() {
  runApp(MaterialApp(home: DefectDashboard(),  debugShowCheckedModeBanner: false,
));
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Analyse des Défauts")),
        body: FutureBuilder<bool>(
          future: apiService.authenticate("B.Aziz", "B.Aziz2022"), // Remplace par tes identifiants
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (authSnapshot.hasError || authSnapshot.data == false) {
              return Center(child: Text("Échec de connexion"));
            }

            return FutureBuilder<Map<String, int>>(
              future: apiService.getAggregatedDefects("2025-02-01", "2025-03-30"),
              builder: (context, defectSnapshot) {
                if (defectSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (defectSnapshot.hasError) {
                  return Center(child: Text("Erreur de chargement des défauts"));
                }
                if (defectSnapshot.data == null || defectSnapshot.data!.isEmpty) {
                  return Center(child: Text("Aucun défaut trouvé"));
                }

                final defects = defectSnapshot.data!;

                return ListView.builder(
                  itemCount: defects.length,
                  itemBuilder: (context, index) {
                    String defectName = defects.keys.elementAt(index);
                    int defectCount = defects.values.elementAt(index);
                    return ListTile(
                      title: Text(defectName),
                      subtitle: Text("Nombre : $defectCount"),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
