// domain/entities/investment_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment_data.freezed.dart';
part 'investment_data.g.dart';

enum InvestmentType { cdt, acciones, fondo, otro }

enum CalculationMethod { simple, compuesto }

@freezed
class InvestmentResult with _$InvestmentResult {
  const factory InvestmentResult({
    required String id,
    required String label,
    required InvestmentType type,
    required double amount,
    required double rate,
    required int months,
    required double totalBruto,
    required double totalNeto,
    required double profitBruto,
    required double profitNeto,
    @Default(0.0) double retencionAplicada,
    required CalculationMethod method,
    @Default(0.0) double porcentajeRetencion,
    required List<double>? monthlyRates,
    required List<double>? progressionPoints,
    required List<Map<String, dynamic>> monthlyBreakdown,
  }) = _InvestmentResult;

  factory InvestmentResult.fromJson(Map<String, dynamic> json) =>
      _$InvestmentResultFromJson(json);
}
