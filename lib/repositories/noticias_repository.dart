import '../models/noticia.dart';
import '../services/noticias_service.dart';

class NoticiasRepository {
  final NoticiasService api;
  NoticiasRepository(this.api);

  Future<List<Noticia>> listar() => api.listar();
  Future<Noticia?> byId(String id) => api.byId(id);
}
