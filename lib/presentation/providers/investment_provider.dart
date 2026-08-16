import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simulador_inversion/core/utils/download_helper.dart';
import 'package:simulador_inversion/core/utils/formatters.dart';
import 'package:simulador_inversion/domain/services/pdf_service.dart';
import 'package:simulador_inversion/presentation/providers/filter_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;
import 'dart:math';
import '../../domain/entities/investment_data.dart';
import '../../data/repositories/local_investment_repository.dart';
import 'dart:convert';
import 'package:csv/csv.dart';

part 'investment_provider.g.dart';

@riverpod
class InvestmentController extends _$InvestmentController {
  // Instancia del repositorio para persistencia local
  final _repository = LocalInvestmentRepository();

  @override
  Future<List<InvestmentResult>> build() async {
    // Al inicializar, cargamos los datos guardados en el dispositivo
    return await _repository.loadSimulations();
  }

  /// Añade una nueva simulación al historial y persiste los datos
  /// Añade una nueva simulación al historial y persiste los datos
  Future<void> addSimulation({
    required double amount,
    required double rate,
    required int months,
    required String label,
    required InvestmentType type,
    required double retencionPct,
    required CalculationMethod method,
  }) async {
    double totalBruto;
    double t = months / 12; // Tiempo en años
    double r = rate / 100; // Tasa decimal

    if (method == CalculationMethod.simple) {
      // FÓRMULA INTERÉS SIMPLE: Valor Futuro = P * (1 + (r * t))
      totalBruto = amount * (1 + (r * t));
    } else {
      // FÓRMULA INTERÉS COMPUESTO: Valor Futuro = P * (1 + r)^t
      totalBruto = amount * pow((1 + r), t);
    }

    final double profitBruto = totalBruto - amount;

    // 2. Cálculo de Impuestos (Retención Variable según el tipo de inversión)
    final double retencion = profitBruto * retencionPct;
    final double profitNeto = profitBruto - retencion;
    final double totalNeto = amount + profitNeto;

    final String newId = const Uuid().v4();

    //   Definimos la lista de tasas mensuales inicial
    // Si es Acciones o Fondo, creamos la lista; si es CDT, podemos dejarla en null o vacía
    final List<double>? initialMonthlyRates =
        (type == InvestmentType.acciones || type == InvestmentType.fondo)
        ? List.generate(months, (index) => rate)
        : null;

    // 3. Generar los puntos de la gráfica iniciales (Progression)
    // Empezamos con el capital inicial
    List<double> initialProgression = [amount];
    double runningBalance = amount;

    if (initialMonthlyRates != null) {
      for (var mRate in initialMonthlyRates) {
        runningBalance *= (1 + (mRate / 100));
        initialProgression.add(runningBalance);
      }
    } else {
      // Para CDT (Tasa Fija), usamos la lógica de interés compuesto estándar
      for (int i = 1; i <= months; i++) {
        // Aquí podrías usar tu fórmula de interés compuesto ya definida
        double pointBalance = amount * pow((1 + (rate / 100)), i);
        initialProgression.add(pointBalance);
      }
    }

    // 3. Creación del objeto de resultado (Freezed Entity)
    final initialResult = InvestmentResult(
      id: newId,
      label: label,
      type: type,
      amount: amount,
      rate: rate,
      months: months,
      totalBruto: totalBruto,
      totalNeto: totalNeto,
      profitBruto: profitBruto,
      profitNeto: profitNeto,
      monthlyRates: initialMonthlyRates,
      method: method,
      retencionAplicada: retencion,
      progressionPoints: initialProgression,
      porcentajeRetencion: retencionPct,
      monthlyBreakdown: const [],
    );

    // 2. Pasamos el objeto por nuestro motor financiero centralizado
    final newResult = _calculateFinancialData(initialResult);

    // 4. Actualización del Estado
    // Recuperamos la lista actual o una vacía si es null
    final previousState = state.value ?? <InvestmentResult>[];

    // Creamos la nueva lista con tipado explícito para evitar errores de 'dynamic'
    final newState = <InvestmentResult>[...previousState, newResult];

    // Actualizamos el estado de Riverpod
    state = AsyncData(newState);

    // 5. Persistencia
    // Guardamos en LocalStorage para que no se pierda al recargar la web
    await _repository.saveSimulations(newState);
  }

  /// Borra todo el historial de simulaciones
  Future<void> clearHistory() async {
    state = const AsyncData(<InvestmentResult>[]);
    await _repository.saveSimulations([]);
  }

  // ELIMINAR (Útil ahora que tenemos UUID)
  Future<void> deleteSimulation(String id) async {
    final previousState = state.value ?? [];
    state = AsyncValue.data(previousState.where((s) => s.id != id).toList());

    try {
      await _repository.deleteSimulation(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> exportCurrentFilterToPdf(Map<String, dynamic> summary) async {
    final simulations =
        state.value ?? []; // Ya tienes los datos aquí, no necesitas read

    if (simulations.isEmpty) return;

    await PdfService.generateInversionReport(
      simulations: simulations,
      summary: summary,
    );
  }

  Future<void> exportToPdfWeb(
    InvestmentResult inv,
    Uint8List? chartBytes,
  ) async {
    final pdf = pw.Document();
    final fmt = currencyFormat; // Tu formateador global

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                inv.label.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "Proyección Financiera",
                style: pw.TextStyle(color: PdfColors.grey),
              ),
            ],
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),
          // INSERTAR LA GRÁFICA SI EXISTEN BYTES
          if (chartBytes != null) ...[
            pw.Text(
              "Evolución del Patrimonio",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              height: 200,
              child: pw.Image(pw.MemoryImage(chartBytes)),
            ),
            pw.SizedBox(height: 20),
          ],
          pw.SizedBox(height: 10),
          // Resumen
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Capital Invertido: ${fmt.format(inv.amount)}"),
              pw.Text("Tasa Base: ${inv.rate}% E.A."),
              pw.Text(
                "Retención: ${fmt.format(inv.retencionAplicada)} - Porcentaje: ${inv.porcentajeRetencion} %",
              ),
              pw.Text("Total Bruto: ${fmt.format(inv.totalBruto)}"),
              pw.Text(
                "Resultado Neto: ${fmt.format(inv.totalNeto)}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Tabla de Desglose
          pw.Text(
            "Tabla de Proyección Mensual",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Mes', '% E.A.', 'Interés Ganado', 'Saldo Acumulado'],
            data: inv.monthlyBreakdown.map((row) {
              return [
                row['mes'].toString(),
                row['tasaEA'] != null ? "${row['tasaEA']}%" : "-",
                fmt.format(row['interes']),
                fmt.format(row['saldo']),
              ];
            }).toList(),
            columnWidths: {
              0: const pw.FixedColumnWidth(40),
              1: const pw.FixedColumnWidth(60),
              2: const pw.FixedColumnWidth(100),
              3: const pw.FixedColumnWidth(100),
            },
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              "Nota: Los valores de retención en la fuente se calculan sobre los rendimientos mensuales generados.",
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    await downloadPdfWeb(pdf, "Inversion_${inv.label.replaceAll(' ', '_')}");
  }

  // Ahora, en updateMonthlyRate, simplemente llamamos al calculador
  Future<void> updateMonthlyRate(String id, int index, double rate) async {
    final currentState = state.value ?? [];
    state = AsyncValue.data(
      currentState.map((inv) {
        if (inv.id == id) {
          final newRates = List<double>.from(inv.monthlyRates!);
          newRates[index] = rate;
          return _calculateFinancialData(inv.copyWith(monthlyRates: newRates));
        }
        return inv;
      }).toList(),
    );

    // Persistencia...
    await _repository.saveSimulations(state.value!);
  }

  // Lógica de interés compuesto con tasas variables
  InvestmentResult _recalculateWithVariableRates(InvestmentResult inv) {
    double balance = inv.amount;
    final rates = inv.monthlyRates!;

    for (var rate in rates) {
      balance *= (1 + (rate / 100));
    }

    // Lista para la gráfica y el desglose
    List<double> newProgression = [balance];

    for (var rate in rates) {
      balance *= (1 + (rate / 100));
      newProgression.add(balance); // Guardamos cada punto
    }

    // Retornamos la inversión con los nuevos totales calculados
    return inv.copyWith(
      totalBruto: balance,
      // Aquí podrías restar la retención si aplica, similar a tu lógica de CDT
      totalNeto: balance,
      profitBruto: balance - inv.amount,
      profitNeto: balance - inv.amount,
      progressionPoints: newProgression,
    );
  }

  InvestmentResult _calculateFinancialData(InvestmentResult inv) {
    List<Map<String, dynamic>> breakdown = [];
    List<double> points = [];
    double currentBalance = (inv.amount).toDouble();

    // Punto inicial (Mes 0)
    breakdown.add({
      'mes': 0,
      'interes': 0.0,
      'retefuente': 0.0,
      'saldo': currentBalance,
    });
    points.add(currentBalance);

    final int months = inv.months;
    final double baseRate = (inv.rate).toDouble();
    final double retePct = (inv.porcentajeRetencion).toDouble() / 100;

    // --- MOTOR DE CÁLCULO ---
    if (inv.type == InvestmentType.acciones ||
        inv.type == InvestmentType.fondo) {
      // Renta Variable
      final List<double> rates =
          inv.monthlyRates ?? List.generate(months, (_) => baseRate);

      for (int i = 0; i < months; i++) {
        double currentEA = (rates[i]).toDouble();
        double monthlyRate = (currentEA / 12) / 100;

        double interestBruto = currentBalance * monthlyRate;
        double retencionMes = interestBruto > 0 ? interestBruto * retePct : 0.0;
        double interestNeto = interestBruto - retencionMes;

        currentBalance += interestNeto;

        breakdown.add({
          'mes': i + 1,
          'tasaEA': currentEA,
          'interes': interestNeto,
          'retefuente': retencionMes,
          'saldo': currentBalance,
        });
        points.add(currentBalance);
      }
    } else {
      // Renta Fija (CDT y otros) - Usamos Tasa Compuesta
      double monthlyRate = pow(1 + (baseRate / 100), 1 / 12) - 1;

      for (int i = 0; i < months; i++) {
        double interestBruto = currentBalance * monthlyRate;
        double retencionMes = interestBruto > 0 ? interestBruto * retePct : 0.0;
        double interestNeto = interestBruto - retencionMes;

        currentBalance += interestNeto;

        breakdown.add({
          'mes': i + 1,
          'tasaEA': baseRate,
          'interes': interestNeto,
          'retefuente': retencionMes,
          'saldo': currentBalance,
        });
        points.add(currentBalance);
      }
    }

    // --- TOTALIZACIÓN BLINDADA ---
    double sumaInteresNeto = 0.0;
    double sumaRetenciones = 0.0;

    for (var step in breakdown) {
      // Sumamos solo lo que se generó mes a mes
      sumaInteresNeto += (step['interes'] as num?)?.toDouble() ?? 0.0;
      sumaRetenciones += (step['retefuente'] as num?)?.toDouble() ?? 0.0;
    }

    // Profit Bruto: Lo que ganó antes de impuestos
    final double profitBrutoTotal = sumaInteresNeto + sumaRetenciones;

    // Profit Neto: Lo que realmente le queda de ganancia
    final double profitNetoTotal = sumaInteresNeto;

    // Neto Final: Capital Inicial + Ganancia Real
    final double netoFinalReal = (inv.amount) + profitNetoTotal;

    return inv.copyWith(
      profitBruto: profitBrutoTotal,
      retencionAplicada: sumaRetenciones,
      profitNeto: profitNetoTotal,
      totalNeto: netoFinalReal, // <--- ESTO OBLIGA A LA RESTA
      progressionPoints: points,
      monthlyBreakdown: breakdown,
    );
  }

  // --- EXPORTAR A CSV ---
  Future<void> exportToCsv() async {
    final simulations = state.value ?? [];
    List<List<dynamic>> rows = [
      [
        "Entidad",
        "Tipo",
        "Inversion",
        "Tasa EA",
        "Meses",
        "Bruto",
        "Retencion",
        "Ganancia Neta",
        "Total",
      ],
    ];

    for (var s in simulations) {
      rows.add([
        s.label,
        s.type.name,
        s.amount,
        s.rate,
        s.months,
        s.profitBruto,
        s.retencionAplicada,
        (s.profitBruto - s.retencionAplicada),
        s.totalNeto,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    downloadFileWeb(csvData, "reporte_inversiones.csv", "text/csv");
  }

  // --- EXPORTAR A JSON (Backup Completo) ---
  Future<void> exportToJson() async {
    final simulations = state.value ?? [];
    final jsonData = jsonEncode(simulations.map((s) => s.toJson()).toList());

    downloadFileWeb(jsonData, "backup_simulaciones.json", "application/json");
  }

  // --- IMPORTAR DESDE JSON ---
  void importWithNativeInput() {
    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';
    input.accept = '.json';

    input.onChange.listen((event) {
      final file = input.files?.item(0);
      if (file != null) {
        final reader = web.FileReader();
        reader.readAsText(file);
        reader.onLoadEnd.listen((progressEvent) {
          try {
            final content = reader.result as String;
            final List<dynamic> decoded = jsonDecode(content);

            final List<InvestmentResult> imported = decoded.map((item) {
              final inv = InvestmentResult.fromJson(item);
              // Re-calculamos con tu lógica financiera (la de la retención del 4% y demás)
              return _calculateFinancialData(inv);
            }).toList();

            // 4. Actualizamos el estado de Riverpod
            state = AsyncValue.data([...state.value ?? [], ...imported]);
          } catch (e) {
            print("Error al procesar el JSON: $e");
          }
        });
      }
    });

    input.click();
  }
}

@riverpod
List<InvestmentResult> filteredSimulations(FilteredSimulationsRef ref) {
  // Observamos el Notifier de inversiones (el que ya tienes con UUID y persistencia)
  final allSimsAsync = ref.watch(investmentControllerProvider);

  // Observamos los nuevos notifiers de filtro
  final searchQuery = ref.watch(searchFilterProvider).toLowerCase();
  final selectedType = ref.watch(typeFilterProvider);

  final allSims = allSimsAsync.value ?? [];

  return allSims.where((sim) {
    final matchesSearch = sim.label.toLowerCase().contains(searchQuery);
    final matchesType = selectedType == null || sim.type == selectedType;
    return matchesSearch && matchesType;
  }).toList();
}

@riverpod
Map<String, dynamic> portfolioSummary(PortfolioSummaryRef ref) {
  final filteredList = ref.watch(filteredSimulationsProvider);

  double totalInvertido = 0;
  double totalNetoProyectado = 0;
  double totalGananciaNeta = 0;
  double totalRetencion = 0; // <--- Nueva variable

  for (var sim in filteredList) {
    totalInvertido += sim.amount;
    totalNetoProyectado += sim.totalNeto;
    totalGananciaNeta += sim.profitNeto;
    totalRetencion += sim.retencionAplicada; // <--- Acumulamos la retención
  }

  return {
    'invested': totalInvertido,
    'projected': totalNetoProyectado,
    'profit': totalGananciaNeta,
    'retention': totalRetencion, // <--- La añadimos al mapa
    'count': filteredList.length,
  };
}
