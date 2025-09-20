//Este archivo almacena el modelo de usuario empleado

class Usuario{
  final String idU;
  final String nombreU;
  final String correoU;
  final String? FotoPerfil;

  Usuario({
    required this.idU,
    required this.nombreU,
    required this.correoU,
    required this.FotoPerfil,
  });

  Map<String,dynamic> toMap()=> {
    'uid':idU,
    'nombreU':nombreU,
    'correU':correoU,
    'FotoPerfil':FotoPerfil,
  };

  static Usuario fromMap(Map<String,dynamic> m) => Usuario(
    idU: m['idU'],
    nombreU: m['nombreU'],
    correoU: m['correoU'],
    FotoPerfil: m['FotoPerfil'],
  );
}