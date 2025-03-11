import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.1.198:8081/QalitasWebApi";
  String? _accessToken;

  // 🔹 Authentification et récupération du token
  Future<bool> authenticate(String username, String password) async {
    final url = Uri.parse("$baseUrl/token");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": username,
        "password": password,
        "grant_type": "password",
        "groupId": "14538e00-c82d-5dfc-99cf-39e4103aa540",
        "siteId": "c57a7dcc-09a3-9a2c-7a8e-39e4103aa520",
        "companyId": "05a0af1b-6ef5-de47-30a5-39e4103aa530"
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      return true;
    } else {
      return false;
    }
  }

  // 🔹 Récupérer et compter les occurrences des défauts en tenant compte de la quantité
Future<Map<String, int>> getAggregatedDefects(String startDate, String endDate) async {
  if (_accessToken == null) {
    throw Exception("Token non disponible, authentifiez-vous d'abord.");
  }

  final url = Uri.parse(
    "$baseUrl/api/QualityControls/filterNCP?filter={'PeriodFilter':'1','StartDate':'$startDate','EndDate':'$endDate'}"
  );

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $_accessToken",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    Map<String, int> defectCounts = {};

    for (var item in data) {
      String defect = item['defectDesignation'] ?? "Inconnu";
      int quantity = (item['quantity'] ?? 1).toInt(); // Convertit en int

      defectCounts[defect] = (defectCounts[defect] ?? 0) + quantity;
    }

    return defectCounts;
  } else {
    throw Exception("Erreur API: ${response.statusCode}");
  }
}

  Future<Map<String, int>> getDefectsByCategory(String startDate, String endDate) async {
  if (_accessToken == null) {
    throw Exception("Token non disponible, authentifiez-vous d'abord.");
  }

  final url = Uri.parse(
    "$baseUrl/api/QualityControls/filterNCP?filter={'PeriodFilter':'1','StartDate':'$startDate','EndDate':'$endDate'}"
  );

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $_accessToken",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    Map<String, int> categoryCounts = {};

    for (var item in data) {
            int quantity = (item['quantity'] ?? 1).toInt(); // Convertit en int

      String category = item['defectCategory'] ?? "Autre";
      categoryCounts[category] = (categoryCounts[category] ?? 0) + quantity;
    }

    return categoryCounts;
  } else {
    throw Exception("Erreur API: ${response.statusCode}");
  }
}

Future<Map<String, int>> getDefectCategories(String startDate, String endDate) async {
  if (_accessToken == null) {
    throw Exception("Token non disponible, authentifiez-vous d'abord.");
  }

  final url = Uri.parse(
      "$baseUrl/api/QualityControls/filterNCP?filter={'PeriodFilter':'1','StartDate':'$startDate','EndDate':'$endDate'}");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $_accessToken",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    if (data.isEmpty) return {}; // Si aucun défaut trouvé, retourner une map vide
print("data length:::${data.length}");
    // Agréger les catégories
    Map<String, int> categoryCounts = {};
    for (var item in data) {
            int quantity = (item['quantity'] ?? 1).toInt(); // Convertit en int

      String category = item['defectCategory'] ?? 'Inconnu';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + quantity;
    }

    return categoryCounts;
  } else {
    throw Exception("Échec de récupération des catégories: ${response.statusCode}");
  }
}

}
