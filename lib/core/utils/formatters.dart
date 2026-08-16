import 'package:intl/intl.dart';

// Definición global para usar en cualquier parte de la app
final NumberFormat currencyFormat = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0, // En pesos colombianos usualmente no usamos decimales
);

// Extension para facilitar el uso desde cualquier double
extension DoubleFormater on double {
  String toCurrency() => currencyFormat.format(this);
}
