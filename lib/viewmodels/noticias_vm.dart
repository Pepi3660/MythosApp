import 'package:flutter/foundation.dart';
import '../models/noticia.dart';
import '../repositories/noticias_repository.dart';

class NoticiasVM extends ChangeNotifier {
  final NoticiasRepository repo;
  NoticiasVM(this.repo);

  bool _loading = false;
  List<Noticia> _items = [];

  bool get loading => _loading;
  List<Noticia> get items => _items;

  // Alias para evitar errores si alguna vista usa "noticias"
  List<Noticia> get noticias => _items;

  Future<void> cargar() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await repo.listar();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Noticia? byId(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
