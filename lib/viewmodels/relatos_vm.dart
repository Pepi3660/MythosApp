//Logica que controla la vista de los relatos

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/relato.dart';
import '../services/RelatoService.dart';

class RelatosVM extends ChangeNotifier {
  final RelatoService _service;
  RelatosVM(this._service);

  bool cargando = false;
  String? error;
  List<Relato> relatos = [];

  Future<void> cargar() async {
    try {
      cargando = true; error = null; notifyListeners();
      relatos = await _service.feed();
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false; notifyListeners();
    }
  }

  Future<String> crearTexto(String texto, {GeoPoint? ubicacion}) async {
    try {
      cargando = true; notifyListeners();
      final id = await _service.crearRelato(
        tipoP: 'texto',
        contenido: texto,
        ubicacion: ubicacion,
      );
      await cargar();
      return id;
    } finally {
      cargando = false; notifyListeners();
    }
  }

  Future<String> crearImagen(File imagen, {GeoPoint? ubicacion}) async {
    try {
      cargando = true; notifyListeners();
      final id = await _service.crearRelato(
        tipoP: 'imagen',
        contenido: '',
        imagen: imagen,
        ubicacion: ubicacion,
      );
      await cargar();
      return id;
    } finally {
      cargando = false; notifyListeners();
    }
  }
}
