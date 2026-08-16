import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:simulador_inversion/core/utils/formatters.dart';
import 'package:simulador_inversion/domain/entities/investment_data.dart';
// ... imports de tus modelos

class PdfService {
  static Future<void> generateInversionReport({
    required List<InvestmentResult> simulations,
    required Map<String, dynamic> summary,
  }) async {
    final pdf = pw.Document();
    final fmt = currencyFormat;

    // 1. Buscamos la ganancia neta más alta para escalar el gráfico
    double maxGanancia = simulations.fold(0.0, (max, sim) {
      final neta = sim.profitBruto - sim.retencionAplicada;
      return neta > max ? neta : max;
    });

    // 2. Le damos un margen del 20% arriba para que no toque el techo
    double upperLimit = maxGanancia * 1.2;

    // 3. Creamos 5 saltos proporcionales
    List<double> ySteps = List.generate(6, (i) => (upperLimit / 5) * i);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Reporte de Portafolio de Inversiones"),
          ),

          // Sección de Resumen (El Card que hicimos, pero en PDF)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _pdfSummaryItem(
                  "Patrimonio Total",
                  fmt.format(summary['projected']),
                ),
                _pdfSummaryItem("Ganancia Neta", fmt.format(summary['profit'])),
                _pdfSummaryItem(
                  "Impuestos (Rete)",
                  fmt.format(summary['retention']),
                  color: PdfColors.red,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),
          // Dentro de generateInversionReport en PdfService
          pw.Column(
            children: [
              pw.Text(
                "Distribución por Entidad / Inversión",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                height: 200,
                child: pw.Chart(
                  grid: pw.CartesianGrid(
                    xAxis: pw.FixedAxis([
                      0,
                      1,
                      2,
                      3,
                      4,
                      5,
                    ]), // Ajustar según número de simulaciones
                    yAxis: pw.FixedAxis(
                      ySteps, // <--- Usamos los saltos dinámicos
                      format: (v) {
                        if (v >= 1000000) {
                          return "${(v / 1000000).toStringAsFixed(1)}M";
                        }
                        if (v >= 1000) {
                          return "${(v / 1000).toStringAsFixed(0)}K";
                        }
                        return v.toStringAsFixed(0);
                      },
                    ),
                  ),
                  datasets: List<pw.Dataset>.generate(simulations.length, (
                    index,
                  ) {
                    final gananciaNeta =
                        simulations[index].profitBruto -
                        simulations[index].retencionAplicada;

                    return pw.BarDataSet(
                      color:
                          barColors[index %
                              barColors
                                  .length], // Rota entre colores profesionales
                      width: 20,
                      data: [pw.LineChartValue(index.toDouble(), gananciaNeta)],
                    );
                  }),
                ),
              ),
              pw.SizedBox(height: 30),
            ],
          ),
          // Tabla de Datos
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
            columnWidths: {
              0: const pw.FlexColumnWidth(5), // Nombre/Entidad (más ancho)
              1: const pw.FlexColumnWidth(2), // Tipo
              2: const pw.FlexColumnWidth(3), // Inversión
              3: const pw.FlexColumnWidth(3), // Ganancia Neta
              4: const pw.FlexColumnWidth(3), // Rete
              5: const pw.FlexColumnWidth(3), // Neto Final
            },
            headers: [
              'Entidad',
              'Tipo',
              'Inversión',
              'G. Neta',
              'Ret. Neta',
              'Neto Final',
            ],
            data: simulations.asMap().entries.map((entry) {
              final index = entry.key;
              final sim = entry.value;
              final gananciaNeta = sim.profitBruto - sim.retencionAplicada;

              return [
                // CELDA DEL NOMBRE CON EL INDICADOR DE COLOR
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 8,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: barColors[index % barColors.length],
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(sim.label.isEmpty ? "Sin nombre" : sim.label),
                  ],
                ),
                sim.type.name.toUpperCase(),
                currencyFormat.format(sim.amount),
                currencyFormat.format(gananciaNeta),
                currencyFormat.format(sim.retencionAplicada * -1),
                currencyFormat.format(sim.totalNeto),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // Opción A: Lista de colores profesionales predefinidos
  static final List<PdfColor> barColors = [
    PdfColors.blue900,
    PdfColors.teal,
    PdfColors.indigo,
    PdfColors.cyan,
    PdfColors.blueGrey700,
    PdfColors.green900,
  ];

  // Opción B: Generador aleatorio (si prefieres caos controlado)
  static PdfColor getRandomColor() {
    final random = math.Random();
    return PdfColor.fromInt(random.nextInt(0xFFFFFF) | 0xFF000000);
  }

  static pw.Widget _pdfSummaryItem(
    String label,
    String value, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
