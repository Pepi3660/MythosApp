import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalendarioView extends StatelessWidget {
  const CalendarioView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          // Encabezado liviano con volver
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Material(
                  color: cs.surface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      final r = GoRouter.of(context);
                      if (r.canPop()) {
                        r.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Calendario',
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                ),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Calendario cultural (pendiente)',
                style: text.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
