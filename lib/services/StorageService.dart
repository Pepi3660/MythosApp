//En este archivo se almacena el servicio de almacenamiento 
//de imagenes con Firebase Storage

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Sube un archivo de imagen y retorna la URL pública de descarga.
  Future<String> uploadEventoImage(File file, {required String fileName}) async {
    final ref = _storage.ref().child('Eventos/$fileName');

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    //URL devuelta por Storage
    final downloadUrl = await task.ref.getDownloadURL();
    return downloadUrl;
  }
}