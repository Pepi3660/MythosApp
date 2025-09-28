//Contiene las configuraciones de relatos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mythosapp/models/relato.dart';

class RelatoRepository {
  final FirebaseFirestore _db;
  RelatoRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Publicaciones');

  Future<List<Relato>> listar({int limite = 50}) async {
    final q = await _col
        .orderBy('FechaCreacion', descending: true)
        .limit(limite)
        .get();
    return q.docs.map((d) => Relato.fromDoc(d)).toList();
  }

  Future<String> crear(Relato r) async {
    final ref = await _col.add(r.toMap());
    await ref.update({'IdP': r.idP.isEmpty ? ref.id : r.idP});
    return ref.id;
  }

  Future<void> comentar(String idRelato, Comentario c) async {
    await _col.doc(idRelato).collection('Comentarios').add(c.toMap());
  }
}
