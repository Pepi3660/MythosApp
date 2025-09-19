class Noticia {
  final String id;
  final String titulo;
  final String resumen;     // breve
  final String contenido;   // cuerpo completo
  final String? coverUrl;   // imagen de portada
  final DateTime fecha;
  final List<String> tags;

  Noticia({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.contenido,
    required this.fecha,
    this.coverUrl,
    this.tags = const [],
  });

  factory Noticia.fromJson(Map<String, dynamic> j) => Noticia(
        id: j['id'] as String,
        titulo: j['titulo'] as String,
        resumen: j['resumen'] as String,
        contenido: j['contenido'] as String,
        coverUrl: j['coverUrl'] as String?,
        fecha: DateTime.parse(j['fecha'] as String),
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'resumen': resumen,
        'contenido': contenido,
        'coverUrl': coverUrl,
        'fecha': fecha.toIso8601String(),
        'tags': tags,
      };
}
