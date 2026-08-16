import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simulador_inversion/core/utils/capture_png_helper.dart';
import 'package:simulador_inversion/core/utils/formatters.dart';
import '../../domain/entities/investment_data.dart';
import '../providers/investment_provider.dart';

class InvestmentDetailScreen extends ConsumerWidget {
  final String investmentId;
  final GlobalKey chartKey = GlobalKey();

  InvestmentDetailScreen({super.key, required this.investmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos la lista de inversiones del controlador
    final investmentsAsync = ref.watch(investmentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Inversión"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              // 1. Capturamos la gráfica de la pantalla
              final bytes = await capturePng(chartKey);

              // 2. Obtenemos la inversión
              final inv = ref
                  .read(investmentControllerProvider)
                  .value!
                  .firstWhere((e) => e.id == investmentId);

              // 3. Generamos el PDF con la imagen incluida
              ref
                  .read(investmentControllerProvider.notifier)
                  .exportToPdfWeb(inv, bytes);
            },
          ),
        ],
      ),
      body: investmentsAsync.when(
        data: (list) {
          // Buscamos la inversión específica por ID
          final inv = list.firstWhere((e) => e.id == investmentId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(inv),
                const SizedBox(height: 24),

                const Text(
                  "Progresión del Patrimonio",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RepaintBoundary(
                  key: chartKey,
                  child: _buildChartSection(inv),
                ), // Ahora solo lee inv.progressionPoints

                const SizedBox(height: 24),

                // Sección de Ajustes Mensuales (Solo si aplica)
                if (inv.type == InvestmentType.acciones ||
                    inv.type == InvestmentType.fondo)
                  _buildAdjustmentSection(context, ref, inv),

                const SizedBox(height: 24),

                const Text(
                  "Desglose Mensual",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildBreakdownTable(
                  inv,
                ), // Ahora solo lee inv.monthlyBreakdown
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error al cargar: $e")),
      ),
    );
  }

  // --- SUB-WIDGETS DE LA UI (SIN LÓGICA DE CÁLCULO) ---

  Widget _buildHeaderCard(InvestmentResult inv) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              inv.label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn("Invertido", currencyFormat.format(inv.amount)),
                _buildInfoColumn(
                  "Neto Final",
                  currencyFormat.format(inv.totalNeto),
                  color: Colors.green,
                ),
                _buildInfoColumn(
                  "Rendimiento",
                  "${inv.rate}% ${inv.type == InvestmentType.cdt ? 'E.A' : 'Est.'}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildChartSection(InvestmentResult inv) {
    List<FlSpot> spots = inv.progressionPoints!.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    if (spots.isEmpty) return const SizedBox.shrink();

    // Ajustamos los límites para que la línea no toque los bordes del contenedor
    double minY = inv.amount * 0.98;
    double maxY = inv.totalNeto * 1.02;

    return SizedBox(
      height: 180, // <-- ALTURA FIJA: Controlamos el crecimiento vertical
      width: double.infinity,
      child: Card(
        // Cambiamos Container por Card para dar elevación y bordes limpios
        elevation: 0,
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 20,
            left: 10,
            top: 20,
            bottom: 10,
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                // Solo mostramos títulos abajo para ahorrar espacio
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: (inv.months / 4).clamp(1, 12).toDouble(),
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        "M${value.toInt()}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: inv.months.toDouble(),
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.indigo.withOpacity(0.9),
                  tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((barSpot) {
                      return LineTooltipItem(
                        currencyFormat.format(barSpot.y),
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: inv.type == InvestmentType.acciones
                      ? Colors.green
                      : Colors.indigo,
                  barWidth:
                      2.5, // Línea un poco más delgada para verse más fina
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (inv.type == InvestmentType.acciones
                                ? Colors.green
                                : Colors.indigo)
                            .withOpacity(0.15),
                        (inv.type == InvestmentType.acciones
                                ? Colors.green
                                : Colors.indigo)
                            .withOpacity(0.01),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentSection(
    BuildContext context,
    WidgetRef ref,
    InvestmentResult inv,
  ) {
    return ExpansionTile(
      title: const Text("Ajustar Rendimientos Reales"),
      subtitle: const Text("Modifica las tasas mes a mes"),
      leading: const Icon(Icons.edit_note, color: Colors.indigo),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: inv.months,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("Mes ${index + 1}"),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue:
                      inv.monthlyRates?[index].toString() ??
                      inv.rate.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Requerido";
                    final normalized = val.replaceAll(',', '.');
                    if (double.tryParse(normalized) == null) return "Inválido";
                    return null;
                  },
                  decoration: const InputDecoration(
                    suffixText: "%",
                    isDense: true,
                    errorStyle: TextStyle(fontSize: 9),
                  ),
                  onFieldSubmitted: (val) {
                    final normalized = val.replaceAll(',', '.');
                    final newRate = double.tryParse(normalized);
                    if (newRate != null) {
                      ref
                          .read(investmentControllerProvider.notifier)
                          .updateMonthlyRate(inv.id, index, newRate);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBreakdownTable(InvestmentResult inv) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1), // Mes
        1: FlexColumnWidth(1.5), // % E.A.
        2: FlexColumnWidth(2), // Interés
        3: FlexColumnWidth(2.5), // Saldo
      },
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _HeaderCell("Mes"),
            _HeaderCell("% E.A."),
            _HeaderCell("Interés"),
            _HeaderCell("Saldo"),
          ],
        ),
        ...inv.monthlyBreakdown.map((row) {
          // El mes 0 no tiene tasa ni interés, manejamos el null safety
          final tasa = row['tasaEA'] != null ? "${row['tasaEA']}%" : "-";

          return TableRow(
            children: [
              _DataCell("${row['mes']}"),
              _DataCell(tasa, color: Colors.blueGrey),
              _DataCell(currencyFormat.format(row['interes'])),
              _DataCell(currencyFormat.format(row['saldo']), isBold: true),
            ],
          );
        }),
      ],
    );
  }

  // Helpers rápidos para no repetir código de estilo
  Widget _HeaderCell(String text) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );

  Widget _DataCell(String text, {bool isBold = false, Color? color}) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
        color: color,
      ),
    ),
  );
}
