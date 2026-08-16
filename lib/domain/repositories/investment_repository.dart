// domain/repositories/investment_repository.dart
import '../entities/investment_data.dart';

abstract class InvestmentRepository {
  Future<void> saveSimulations(List<InvestmentResult> simulations);
  Future<List<InvestmentResult>> loadSimulations();
}
