import 'package:flutter/material.dart';

class RelatoCreateView extends StatefulWidget {
  const RelatoCreateView({super.key});

  @override
  State<RelatoCreateView> createState() => _RelatoCreateViewState();
}

class _RelatoCreateViewState extends State<RelatoCreateView> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _cuerpo = TextEditingController();

  @override
  void dispose() {
    _titulo.dispose();
    _cuerpo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo relato')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cuerpo,
              decoration: const InputDecoration(labelText: 'Cuerpo'),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (_form.currentState?.validate() ?? false) {
                  // Aquí llamarías a tu VM para guardar; de momento solo volvemos.
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
