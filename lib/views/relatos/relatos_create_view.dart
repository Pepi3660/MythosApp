import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/relatos_vm.dart';
import '../../widgets/botonPrincipal.dart';

class RelatoNuevoPage extends StatefulWidget {
  const RelatoNuevoPage({super.key});
  @override
  State<RelatoNuevoPage> createState() => _RelatoNuevoPageState();
}

class _RelatoNuevoPageState extends State<RelatoNuevoPage> {
  final _form = GlobalKey<FormState>();

  // Modo de publicación
  String _modo = 'texto'; // 'texto' | 'imagen'

  // Contenido
  final _textoCtrl = TextEditingController();
  File? _img;

  //campos requeridos
  final _tituloCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  String? _categoria; // obligatorio

  // Ubicación
  GeoPoint? _ubic;

  @override
  void dispose() {
    _textoCtrl.dispose();
    _tituloCtrl.dispose();
    _municipioCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint, IconData icon) {
    const darkOliveGreen = Color(0xFF326430);
    const lightGreen = Color(0xFFD7E6DB);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: darkOliveGreen, fontSize: 16),
      filled: true,
      fillColor: lightGreen,
      prefixIcon: Icon(icon, color: darkOliveGreen),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _img = File(x.path));
  }

  Future<void> _submit() async {
    final vm = context.read<RelatosVM>();

    // Validaciones base
    if (!_form.currentState!.validate()) return;

    try {
      if (_modo == 'texto') {
        // Publicar texto
        await vm.crearTexto(
          texto: _textoCtrl.text.trim(),
          titulo: _tituloCtrl.text.trim(),
          municipio: _municipioCtrl.text.trim(),
          categoria: _categoria!.trim(),
          ubicacion: _ubic,
        );
      } else {
        // Publicar imagen
        if (_img == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Selecciona una imagen')));
          return;
        }
        await vm.crearImagen(
          imagen: _img!,
          titulo: _tituloCtrl.text.trim(),
          municipio: _municipioCtrl.text.trim(),
          categoria: _categoria!.trim(),
          ubicacion: _ubic,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RelatosVM>();
    final cs = Theme.of(context).colorScheme;

    // Opciones de categorías (ajústalas a tu taxonomía real)
    const categorias = <String>[
      'Cuento / Tradición',
      'Gastronomía',
      'Artesanía',
      'Música / Danza',
      'Historia local',
      'Costumbre',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo relato')),
      body: AbsorbPointer(
        absorbing: vm.cargando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de modo
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'texto', icon: Icon(Icons.text_fields), label: Text('Texto')),
                    ButtonSegment(value: 'imagen', icon: Icon(Icons.image_outlined), label: Text('Imagen')),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (s) => setState(() => _modo = s.first),
                ),
                const SizedBox(height: 16),

                //Campos obligatorios nuevos
                TextFormField(
                  controller: _tituloCtrl,
                  style: const TextStyle(color: Color(0xFF326430), fontWeight: FontWeight.w600),
                  decoration: _decor('Título del relato', Icons.title),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _municipioCtrl,
                  style: const TextStyle(color: Color(0xFF326430)),
                  decoration: _decor('Municipio', Icons.location_city_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _categoria,
                  style: const TextStyle(color: Color(0xFF326430), fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: const TextStyle(
                        color: Color(0xFF326430), // darkOliveGreen solo en label
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                        color: Color(0xFF326430),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFD7E6DB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  dropdownColor: const Color(0xFFD7E6DB),
                  items: categorias
                      .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                      .toList(),
                  validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una categoría' : null,
                  onChanged: (v) => setState(() => _categoria = v),
                ),

                const SizedBox(height: 16),

                // Contenido según modo
                if (_modo == 'texto') ...[
                  TextFormField(
                    controller: _textoCtrl,
                    style: const TextStyle(color: Color(0xFF326430)),
                    minLines: 5,
                    maxLines: 8,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Escribe algo' : null,
                    decoration: _decor('¿Qué quieres contar?', Icons.edit_outlined),
                  ),
                ] else ...[
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Elegir imagen'),
                      ),
                      const SizedBox(width: 12),
                      if (_img != null)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_img!, height: 70, fit: BoxFit.cover),
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                //Ubicación
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(_ubic == null ? 'Sin ubicación' : 'Ubicación establecida'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _ubic = null),
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Publicar',
                  loading: vm.cargando,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                if (vm.cargando)
                  LinearProgressIndicator(
                    color: cs.primary,
                    backgroundColor: cs.surfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
