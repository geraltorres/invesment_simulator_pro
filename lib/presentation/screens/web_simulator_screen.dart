import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simulador_inversion/core/utils/formatters.dart';
import 'package:simulador_inversion/domain/entities/investment_data.dart';
import 'package:simulador_inversion/presentation/providers/filter_provider.dart';
import 'package:simulador_inversion/presentation/screens/comparison_screen.dart';
import 'package:simulador_inversion/presentation/screens/investment_detail_screen.dart';
import '../providers/investment_provider.dart';

class WebSimulatorScreen extends ConsumerStatefulWidget {
  const WebSimulatorScreen({super.key});

  @override
  ConsumerState<WebSimulatorScreen> createState() => _WebSimulatorScreenState();
}

class _WebSimulatorScreenState extends ConsumerState<WebSimulatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para el formulario
  final _amountCtrl = TextEditingController(text: "1000000");
  final _rateCtrl = TextEditingController(text: "12.5");
  final _monthsCtrl = TextEditingController(text: "12");
  final _entityController = TextEditingController();

  final Set<String> _selectedInversionIds = {};

  InvestmentType _tipoSeleccionado = InvestmentType.cdt;
  CalculationMethod _metodoSeleccionado = CalculationMethod.compuesto;
  double _retencionVariable = 0.04; // 4% por defecto

  bool _aplicarRetencion = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _monthsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simulationsAsync = ref.watch(investmentControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        title: const Text(
          "Simulador de Inversión Pro",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(investmentControllerProvider.notifier).clearHistory(),
            icon: const Icon(Icons.delete_outline),
            tooltip: "Limpiar Historial",
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: simulationsAsync.when(
        data: (simulations) => _buildDashboard(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error al cargar datos: $err")),
      ),
    );
  }

  Widget _buildDashboard() {
    final simulations = ref.watch(filteredSimulationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 900;

              return Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PANEL IZQUIERDO: FORMULARIO
                  SizedBox(
                    width: isDesktop ? 380 : double.infinity,
                    child: _buildInputForm(simulations.length),
                  ),
                  const SizedBox(width: 24, height: 24),
                  // PANEL DERECHO: COMPARATIVA Y ESTADÍSTICAS
                  Expanded(
                    flex: isDesktop ? 1 : 0,
                    child: Column(
                      children: [
                        _buildResumeCard(ref),
                        const SizedBox(height: 24),
                        // Buscador
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Buscar inversión",
                            hintText:
                                "Ej: 'CDT Bancolombia' o 'Acciones Ecopetrol'",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                ref.watch(searchFilterProvider).isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: null,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) => ref
                              .read(searchFilterProvider.notifier)
                              .update(val),
                          // ...
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<InvestmentType?>(
                          value: ref.watch(typeFilterProvider),
                          isExpanded:
                              true, // Para evitar el overflow que corregimos antes
                          decoration: InputDecoration(
                            labelText: "Filtrar por Tipo",
                            prefixIcon: const Icon(Icons.filter_list),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // Mapeamos los valores del enum a items del dropdown
                          items: [
                            // Opción para limpiar el filtro
                            const DropdownMenuItem<InvestmentType?>(
                              value: null,
                              child: Text("Todos los tipos"),
                            ),
                            // Opciones del enum
                            ...InvestmentType.values.map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              ),
                            ),
                          ],
                          onChanged: (val) =>
                              ref.read(typeFilterProvider.notifier).update(val),
                        ),
                        _buildHistoryTable(simulations),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResumeCard(WidgetRef ref) {
    final summary = ref.watch(portfolioSummaryProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            "Inversiones",
            "${summary['count']}",
            Icons.list_alt,
          ),
          _buildSummaryItem(
            "Total Invertido",
            currencyFormat.format(summary['invested']),
            Icons.account_balance_wallet,
          ),
          _buildSummaryItem(
            "Rendimiento Neto",
            currencyFormat.format(summary['profit']),
            Icons.trending_up,
            color: Colors.greenAccent,
          ),
          _buildSummaryItem(
            "Patrimonio Total",
            currencyFormat.format(summary['projected']),
            Icons.pie_chart,
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon, {
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputForm(int nextIndex) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              "Nueva Simulación",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Dentro del Column del formulario:
            DropdownButtonFormField<InvestmentType>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(labelText: "Tipo de Inversión"),
              items: InvestmentType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _tipoSeleccionado = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CalculationMethod>(
              value: _metodoSeleccionado,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Método de Capitalización",
                prefixIcon: Icon(Icons.functions),
              ),
              items: CalculationMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(
                    method == CalculationMethod.simple
                        ? "Interés Simple (Renta Fija)"
                        : "Interés Compuesto (Acciones/CDT)",
                    overflow: TextOverflow
                        .ellipsis, // 2. Si no cabe, pone puntos suspensivos
                    style: const TextStyle(
                      fontSize: 13,
                    ), // 3. Opcional: bajar un poco la fuente
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _metodoSeleccionado = val!),
            ),
            const SizedBox(height: 8),
            Text(
              _metodoSeleccionado == CalculationMethod.simple
                  ? "Los intereses se pagan al final y no se reinvierten."
                  : "Los intereses generan nuevos rendimientos cada mes.",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Retención: ${(_retencionVariable * 100).toStringAsFixed(1)}%",
            ),
            Opacity(
              opacity: _aplicarRetencion ? 1.0 : 0.4,
              child: AbsorbPointer(
                absorbing: !_aplicarRetencion,
                child: Slider(
                  value: _retencionVariable,
                  min: 0,
                  max: 0.35,
                  divisions: 35,
                  label: "${(_retencionVariable * 100).toStringAsFixed(1)}%",
                  onChanged: (val) => setState(() => _retencionVariable = val),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              _amountCtrl,
              "Monto Inicial",
              Icons.attach_money,
              isNumeric: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _rateCtrl,
              "Tasa E.A. (%)",
              Icons.percent,
              isNumeric: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _monthsCtrl,
              "Plazo (Meses)",
              Icons.calendar_today,
              isNumeric: true,
              isInteger: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(_entityController, "Entidad", Icons.business),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Aplicar Retención"),
              subtitle: Text(
                _aplicarRetencion
                    ? "Tasa: ${(_retencionVariable * 100).toStringAsFixed(1)}%"
                    : "Sin retención aplicada",
              ),
              value: _aplicarRetencion,
              activeColor: Colors.indigo,
              onChanged: (val) => setState(() => _aplicarRetencion = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(investmentControllerProvider.notifier)
                        .addSimulation(
                          amount: double.tryParse(_amountCtrl.text) ?? 0,
                          rate: double.tryParse(_rateCtrl.text) ?? 0,
                          months: int.tryParse(_monthsCtrl.text) ?? 0,
                          method: _metodoSeleccionado,
                          label: _entityController.text,
                          type: _tipoSeleccionado,
                          // Lógica clave: si el toggle está apagado, la retención es 0
                          retencionPct: _aplicarRetencion
                              ? (_retencionVariable * 100)
                              : 0.0,
                        );
                  }
                },
                child: const Text(
                  "CALCULAR Y GUARDAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildHistoryTable(List<InvestmentResult> simulations) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Comparativa de Resultados",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (_selectedInversionIds.length == 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  final toCompare = simulations
                      .where((s) => _selectedInversionIds.contains(s.id))
                      .toList();

                  if (toCompare.length == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparisonScreen(
                          inv1: toCompare[0],
                          inv2: toCompare[1],
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text("COMPARAR RENDIMIENTOS"),
              ),
            ),
          simulations.isNotEmpty
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // BOTÓN IMPORTAR
                        ImporButtonWidget(ref: ref),
                        const SizedBox(width: 12),
                        // BOTÓN EXPORTAR JSON
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(investmentControllerProvider.notifier)
                              .exportToJson(),
                          icon: const Icon(Icons.file_download),
                          label: const Text('Exportar JSON'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade700,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // BOTÓN EXPORTAR CSV
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(investmentControllerProvider.notifier)
                              .exportToCsv(),
                          icon: const Icon(Icons.grid_on),
                          label: const Text('Exportar Excel (CSV)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final summary = ref.read(portfolioSummaryProvider);
                            ref
                                .read(investmentControllerProvider.notifier)
                                .exportCurrentFilterToPdf(summary);
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Exportar Reporte a PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                )
              : SizedBox.shrink(),
          simulations.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No hay simulaciones guardadas aún.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ImporButtonWidget(ref: ref),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    horizontalMargin: 20,
                    columnSpacing: 30,

                    headingRowColor: WidgetStateProperty.all(
                      Colors.grey.shade50,
                    ),
                    columns: const [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("TIPO")),
                      DataColumn(label: Text("ENTIDAD")),
                      DataColumn(label: Text("INVERSIÓN")), // Nueva columna
                      DataColumn(label: Text("BRUTO")),
                      DataColumn(label: Text("RETENCIÓN")),
                      DataColumn(label: Text("NETO FINAL")),
                      DataColumn(label: Text("")),
                    ],
                    rows: simulations.map((sim) {
                      return DataRow(
                        key: ValueKey(sim.id),
                        selected: _selectedInversionIds.contains(sim.id),
                        onSelectChanged: null,
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Text(sim.type.name),
                                const SizedBox(width: 8),
                                if (sim.type == InvestmentType.cdt)
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 14,
                                    color: Colors.blueGrey,
                                  )
                                else
                                  const Icon(
                                    Icons.show_chart,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            _buildSelectableCell(
                              child: _buildTypeBadge(sim.type),
                              inversion: sim,
                            ),
                          ),
                          DataCell(
                            _buildSelectableCell(
                              child: Text(
                                sim.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              inversion: sim,
                            ),
                          ),
                          DataCell(
                            _buildSelectableCell(
                              child: Text(currencyFormat.format(sim.amount)),
                              inversion: sim,
                            ),
                          ),
                          DataCell(
                            _buildSelectableCell(
                              child: Text(
                                currencyFormat.format(sim.profitBruto),
                              ),
                              inversion: sim,
                            ),
                          ),
                          DataCell(
                            _buildSelectableCell(
                              child: Text(
                                "- ${currencyFormat.format(sim.retencionAplicada)}",
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              inversion: sim,
                            ),
                          ),
                          DataCell(
                            _buildSelectableCell(
                              child: Text(
                                currencyFormat.format(sim.totalNeto),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              inversion: sim,
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                // Llamar al método delete del provider usando el sim.id
                                ref
                                    .read(investmentControllerProvider.notifier)
                                    .deleteSimulation(sim.id);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSelectableCell({
    required Widget child,
    required InvestmentResult inversion,
  }) {
    return InkWell(
      // CLIC SENCILLO: Ir al detalle
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvestmentDetailScreen(investmentId: inversion.id),
          ),
        );
      },
      // CLIC LARGO: Seleccionar para comparar
      onLongPress: () => _onRowSelected(true, inversion),
      child: Container(
        alignment: Alignment.centerLeft,
        width: double.infinity,
        height: double.infinity,
        child: child,
      ),
    );
  }

  Widget _buildTypeBadge(InvestmentType type) {
    Color color;
    switch (type) {
      case InvestmentType.cdt:
        color = Colors.blue;
        break;
      case InvestmentType.acciones:
        color = Colors.purple;
        break;
      case InvestmentType.fondo:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isInteger = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumeric
          ? TextInputType.numberWithOptions(decimal: !isInteger)
          : TextInputType.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: isNumeric
          ? [
            FilteringTextInputFormatter.allow(
              isInteger ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
            ),
          ]
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Este campo es requerido";
        }
        if (isNumeric) {
          final normalizedValue = value.replaceAll(',', '.');
          if (isInteger) {
            if (int.tryParse(normalizedValue) == null) {
              return "Ingresa un número entero válido";
            }
          } else {
            if (double.tryParse(normalizedValue) == null) {
              return "Ingresa un valor numérico válido";
            }
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  void _onRowSelected(bool? _, InvestmentResult inversion) {
    setState(() {
      if (_selectedInversionIds.contains(inversion.id)) {
        _selectedInversionIds.remove(inversion.id);
      } else {
        if (_selectedInversionIds.length < 2) {
          _selectedInversionIds.add(inversion.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Solo puedes comparar 2 inversiones a la vez"),
            ),
          );
        }
      }
    });
  }
}

class ImporButtonWidget extends StatelessWidget {
  const ImporButtonWidget({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => ref
          .read(investmentControllerProvider.notifier)
          .importWithNativeInput(),
      icon: const Icon(Icons.upload_file),
      label: const Text('Importar JSON'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        textStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
