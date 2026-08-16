import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/investment_data.dart';
import '../../domain/repositories/investment_repository.dart';

class LocalInvestmentRepository implements InvestmentRepository {
  static const _key = 'simulations_history';

  @override
  Future<void> saveSimulations(List<InvestmentResult> simulations) async {
    final prefs = await SharedPreferences.getInstance();
    // Freezed ya nos da el método toJson()
    final String encodedData = jsonEncode(simulations);
    await prefs.setString(_key, encodedData);
  }

  @override
  Future<List<InvestmentResult>> loadSimulations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_key);
    if (rawData == null) return [];

    final List<dynamic> decoded = jsonDecode(rawData);
    // Usamos el fromJson generado por Freezed
    return decoded.map((item) => InvestmentResult.fromJson(item)).toList();
  }

  Future<void> deleteSimulation(String id) async {
    final all = await loadSimulations();
    // Filtramos por el UUID que implementamos antes
    final updated = all.where((item) => item.id != id).toList();
    await saveSimulations(updated);
  }
}
