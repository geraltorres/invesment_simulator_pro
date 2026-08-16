import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../domain/entities/investment_data.dart';

class ComparisonScreen extends StatelessWidget {
  final InvestmentResult inv1;
  final InvestmentResult inv2;

  const ComparisonScreen({super.key, required this.inv1, required this.inv2});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    // Generamos ambos desgloses
    final data1 = _generateBreakdown(inv1);
    final data2 = _generateBreakdown(inv2);

    // Cálculos de comparación
    final diffNeto = (inv1.totalNeto - inv2.totalNeto).abs();
    final mejor = inv1.totalNeto > inv2.totalNeto ? inv1 : inv2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Comparativa de Rendimientos"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                _buildComparisonHeader(currency, diffNeto, mejor),
                const SizedBox(height: 24),
                _buildChartCard(data1, data2),
                const SizedBox(height: 24),
                _buildDetailsTable(currency),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateBreakdown(InvestmentResult inv) {
    List<Map<String, dynamic>> data = [];
    double currentBalance = inv.amount;
    int maxMonths = [inv1.months, inv2.months].reduce(max);

    // Mes 0
    data.add({'mes': 0, 'saldo': inv.amount});

    if (inv.method == CalculationMethod.simple) {
      double monthlyInterest = (inv.amount * (inv.rate / 100)) / 12;
      for (int i = 1; i <= maxMonths; i++) {
        // Si el plazo de esta inversión es menor al máximo, se mantiene el saldo
        if (i <= inv.months) currentBalance += monthlyInterest;
        data.add({'mes': i, 'saldo': currentBalance});
      }
    } else {
      double monthlyRate = pow((1 + (inv.rate / 100)), (1 / 12)) - 1;
      for (int i = 1; i <= maxMonths; i++) {
        if (i <= inv.months) {
          double interestMonth = currentBalance * monthlyRate;
          currentBalance += interestMonth;
        }
        data.add({'mes': i, 'saldo': currentBalance});
      }
    }
    return data;
  }

  Widget _buildComparisonHeader(
    NumberFormat fmt,
    double diff,
    InvestmentResult mejor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.orange, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Análisis Comparativo",
                  style: TextStyle(color: Colors.indigo.shade100, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "La mejor opción es '${mejor.label}' por una diferencia de ${fmt.format(diff)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    List<Map<String, dynamic>> d1,
    List<Map<String, dynamic>> d2,
  ) {
    final double maxSaldo = [
      ...d1,
      ...d2,
    ].map((e) => e['saldo'] as double).reduce(max);
    final compactCurrency = NumberFormat.compactCurrency(
      locale: 'es_CO',
      symbol: '\$',
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 40, 20),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 30),
            SizedBox(
              height: 400,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: maxSaldo / 5,
                        getTitlesWidget: (val, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            compactCurrency.format(val),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => const Color(0xFF1F2937),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _createBarData(d1, Colors.indigo),
                    _createBarData(d2, Colors.orange),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createBarData(
    List<Map<String, dynamic>> data,
    Color color,
  ) {
    return LineChartBarData(
      spots: data.map((e) => FlSpot(e['mes'].toDouble(), e['saldo'])).toList(),
      isCurved: true,
      color: color,
      barWidth: 4,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(inv1.label, Colors.indigo),
        const SizedBox(width: 24),
        _legendItem(inv2.label, Colors.orange),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDetailsTable(NumberFormat fmt) {
    return Row(
      children: [
        Expanded(child: _miniDetailCard(inv1, Colors.indigo, fmt)),
        const SizedBox(width: 16),
        Expanded(child: _miniDetailCard(inv2, Colors.orange, fmt)),
      ],
    );
  }

  Widget _miniDetailCard(InvestmentResult inv, Color color, NumberFormat fmt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inv.label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _row("Inversión:", fmt.format(inv.amount)),
            _row("Tasa:", "${inv.rate}% (${inv.method.name})"),
            _row("Neto:", fmt.format(inv.totalNeto), isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
