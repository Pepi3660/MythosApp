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

  // Carga la lista de relatos
  Future<void> cargar() async {
    try {
      cargando = true;
      error = null;
      notifyListeners();

      relatos = await _service.feed();
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // Crea un relato de texto.
  Future<String> crearTexto({
    required String texto,
    required String titulo,
    required String municipio,
    required String categoria,
    GeoPoint? ubicacion,
  }) async {
    try {
      cargando = true;
      notifyListeners();

      final id = await _service.crearRelato(
        tipoP: 'texto',
        contenido: texto,
        titulo: titulo,
        municipio: municipio,
        categoria: categoria,
        ubicacion: ubicacion,
      );

      await cargar();
      return id;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // Crea un relato de imagen.
  Future<String> crearImagen({
    required File imagen,
    required String titulo,
    required String municipio,
    required String categoria,
    GeoPoint? ubicacion,
  }) async {
    try {
      cargando = true;
      notifyListeners();

      final id = await _service.crearRelato(
        tipoP: 'imagen',
        contenido: '',
        imagen: imagen,
        titulo: titulo,
        municipio: municipio,
        categoria: categoria,
        ubicacion: ubicacion,
      );

      await cargar();
      return id;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // Nuevo método para crear un comentario en un relato.
  Future<void> crearComentario({
    required String idRelato,
    required String texto,
    DateTime? fecha,
  }) async {
    try {
      cargando = true;
      notifyListeners();

      // Llama al servicio para agregar el comentario
      await _service.agregarComentario(idRelato, texto);

      // Si deseas reflejar cambios de inmediato en la lista de relatos
      await cargar();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}