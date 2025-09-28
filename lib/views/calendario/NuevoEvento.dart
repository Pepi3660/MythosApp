//En el presente archivo se guarda la pantalla
//en el que se crea un nuevo evento
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mythosapp/widgets/botonPrincipal.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/calendarioViewModel.dart';

class AgregarEventoPage extends StatefulWidget {
  const AgregarEventoPage({super.key});

  @override
  State<AgregarEventoPage> createState() => _AgregarEventoPageState();
}

class _AgregarEventoPageState extends State<AgregarEventoPage> {
  final _form = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final _muniCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _orgCtrl  = TextEditingController();

  DateTime? _fecha;
  File? _imagen;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _lugarCtrl.dispose();
    _muniCtrl.dispose();
    _descCtrl.dispose();
    _tipoCtrl.dispose();
    _orgCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: _fecha ?? now,
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha ?? now),
    );
    setState(() {
      _fecha = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
    });
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _imagen = File(x.path));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora')),
      );
      return;
    }
    final vm = context.read<CalendarioViewModel>();
    try {
      final id = await vm.crearEvento(
        nombreE: _nombreCtrl.text.trim(),
        fecha: _fecha!,
        nombreLugar: _lugarCtrl.text.trim(),
        municipio: _muniCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        tipoEvento: _tipoCtrl.text.trim(),
        organizador: _orgCtrl.text.trim(),
        imagenLocal: _imagen,
      );
      if (!mounted) return;
      Navigator.pop(context, id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // estilo base similar a RoundedTextField
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarioViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo evento')),
      body: AbsorbPointer(
        absorbing: vm.loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(color: Color(0xFF326430)),
                  controller: _nombreCtrl,
                  decoration: _decor('Nombre del evento', Icons.event_available_outlined),
                  validator: (v) => (v==null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickFecha,
                  child: InputDecorator(
                    decoration: _decor('Fecha y hora', Icons.schedule),
                    child: Text(
                      _fecha == null
                          ? 'Seleccionar'
                          : DateFormat.yMMMMEEEEd(Localizations.localeOf(context).languageCode)
                              .add_Hm()
                              .format(_fecha!),
                      style: const TextStyle(color: Color(0xFF326430)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF326430)),
                  controller: _lugarCtrl,
                  decoration: _decor('Lugar', Icons.place_outlined),
                  validator: (v) => (v==null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF326430)),
                  controller: _muniCtrl,
                  decoration: _decor('Municipio', Icons.location_city_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF326430)),
                  controller: _tipoCtrl,
                  decoration: _decor('Tipo de evento', Icons.category_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF326430)),
                  controller: _orgCtrl,
                  decoration: _decor('Organizador', Icons.person_outline),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF326430)),
                  controller: _descCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _decor('Descripción', Icons.description_outlined),
                ),
                const SizedBox(height: 16),

                // Imagen
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Elegir imagen'),
                    ),
                    const SizedBox(width: 12),
                    if (_imagen != null)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imagen!, height: 60, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón principal con estilo propio
                PrimaryButton(
                  label: 'Guardar',
                  loading: vm.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}