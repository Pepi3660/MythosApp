import 'dart:async';
import '../models/noticia.dart';

class NoticiasService {
  // En el futuro, cambia esto por Firebase/API
  Future<List<Noticia>> listar() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = [..._seed]..sort((a, b) => b.fecha.compareTo(a.fecha));
    return list;
  }

  Future<Noticia?> byId(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _seed.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final List<Noticia> _seed = [
  Noticia(
    id: 'n1',
    titulo: 'Fiesta del Palo de Mayo',
    resumen: 'Historia y significado de esta festividad costeña.',
    contenido:
        'El Palo de Mayo es una celebración tradicional de la Costa Caribe nicaragüense. '
        'Este material describe su origen, música y danza, con testimonios de la comunidad.',
    coverUrl:
        'https://images.unsplash.com/photo-1520975693413-b23f9c60caed?q=80&w=1400&auto=format&fit=crop',
    fecha: DateTime.now().subtract(const Duration(days: 1)),
    tags: const ['tradición', 'danza', 'Costa Caribe'],
  ),
  Noticia(
    id: 'n2',
    titulo: 'Gastronomía popular: Güirila con cuajada',
    resumen: 'Receta y contexto cultural de un platillo clásico.',
    contenido:
        'La güirila es típica del norte del país. Aquí va la receta paso a paso y su contexto cultural.',
    coverUrl:
        'https://images.unsplash.com/photo-1551218808-94e220e084d2?q=80&w=1400&auto=format&fit=crop',
    fecha: DateTime.now().subtract(const Duration(days: 3)),
    tags: const ['receta', 'gastronomía', 'Matagalpa'],
  ),
];
