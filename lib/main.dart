import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/web_simulator_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- IMPORTANTE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CO', null);
  runApp(const ProviderScope(child: InvestmentApp()));
}

class InvestmentApp extends StatelessWidget {
  const InvestmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador Financiero Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const WebSimulatorScreen(),
    );
  }
}
