// presentation/widgets/responsive_dashboard.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget leftPanel; // Formulario
  final Widget rightPanel; // Tabla y Gráficos

  const ResponsiveLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es mayor a 900px, usamos Row (Desktop)
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 380, child: leftPanel),
              const SizedBox(width: 24),
              Expanded(child: rightPanel),
            ],
          );
        } else {
          // Si es menor (Móvil/Tablet), usamos Column
          return Column(
            children: [leftPanel, const SizedBox(height: 24), rightPanel],
          );
        }
      },
    );
  }
}
