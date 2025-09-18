import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:mythosapp/viewmodels/relatos_vm.dart';

class RelatoCreateView extends StatefulWidget {
  const RelatoCreateView({super.key});

  @override
  State<RelatoCreateView> createState() => _RelatoCreateViewState();
}

class _RelatoCreateViewState extends State<RelatoCreateView> {
  final _form = GlobalKey<FormState>();
  final _titCtrl = TextEditingController();
  final _cuerpoCtrl = TextEditingController();

  // ubicación (cascada)
  String? _dep;
  String? _mun;
  String? _barrio;

  // tipo
  String _tipo = 'texto';

  // media
  XFile? _img;

  bool _enviando = false;

  @override
  void dispose() {
    _titCtrl.dispose();
    _cuerpoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x != null) setState(() => _img = x);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RelatosVM>();
    final deps = _depsToMunicipios.keys.toList()..sort();
    final municipios = _dep == null ? <String>[] : (_depsToMunicipios[_dep] ?? const []);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo relato')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              TextFormField(
                controller: _titCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // Tipo
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in const ['texto', 'imagen', 'audio', 'video'])
                    ChoiceChip(
                      label: Text(t),
                      selected: _tipo == t,
                      onSelected: (_) => setState(() => _tipo = t),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_tipo == 'texto')
                TextFormField(
                  controller: _cuerpoCtrl,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Relato (texto)',
                    alignLabelWithHint: true,
                  ),
                ),

              if (_tipo == 'imagen') ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Seleccionar imagen'),
                ),
                if (_img != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_img!.path), height: 160, fit: BoxFit.cover),
                  ),
                ],
              ],

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _dep,
                decoration: const InputDecoration(labelText: 'Departamento'),
                items: deps.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() { _dep = v; _mun = null; _barrio = null; }),
                validator: (v) => v == null ? 'Selecciona un departamento' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _mun,
                decoration: const InputDecoration(labelText: 'Municipio'),
                items: municipios.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() { _mun = v; _barrio = null; }),
                validator: (v) => v == null ? 'Selecciona un municipio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Barrio / Comunidad (opcional)'),
                onChanged: (v) => _barrio = v.trim().isEmpty ? null : v.trim(),
              ),

              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _enviando ? null : () async {
                  if (!_form.currentState!.validate()) return;
                  setState(() => _enviando = true);

                  final ok = await vm.crear(
                    titulo: _titCtrl.text.trim(),
                    cuerpo: _tipo == 'texto' ? _cuerpoCtrl.text.trim() : null,
                    tipo: _tipo,
                    // En tu VM original existe 'municipio'. Guardamos "DEP • MUN" (puedes cambiarlo por campos separados si amplías el modelo).
                    municipio: _barrio == null ? '$_mun, $_dep' : '$_barrio, $_mun, $_dep',
                    media: (_tipo == 'imagen' && _img != null) ? [_img!.path] : const [],
                  );

                  setState(() => _enviando = false);
                  if (ok) Navigator.pop(context);
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se pudo publicar el relato')),
                    );
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(_enviando ? 'Publicando...' : 'Publicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Map<String, List<String>> _depsToMunicipios = {
  'MANAGUA': ['MANAGUA', 'CIUDAD SANDINO', 'TIPITAPA', 'VILLA EL CARMEN'],
  'CARAZO': ['DIRIAMBA', 'JINOTEPE', 'SAN MARCOS'],
  'MASAYA': ['MASAYA', 'NINDIRÍ', 'CATARINA'],
  'LEÓN': ['LEÓN', 'NAGAROTE', 'LA PAZ CENTRO'],
};
