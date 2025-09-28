class MapaTarget {
  final double lat;
  final double lng;
  final String? title;
  final String? snippet;

  const MapaTarget({
    required this.lat,
    required this.lng,
    this.title,
    this.snippet,
  });
}