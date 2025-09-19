import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Botón Volver flotante, reutilizable.
class BackFab extends StatelessWidget {
  final EdgeInsets margin;
  const BackFab({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 0, 0),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        margin: margin,
        alignment: Alignment.topLeft,
        child: Material(
          color: scheme.surface,
          elevation: 4,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
