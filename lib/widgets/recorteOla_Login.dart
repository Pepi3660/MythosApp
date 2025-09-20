//En el presente archivo se almacena las configuraciones
//del recorte en forma de ola del contenedor blanco superior
//que se aprecia en el inicio de sesion

import 'package:flutter/widgets.dart';

//CustomClipper<Path> es una clase abstracta que define
//formas personalizadas para recortar widgets.
class RecorteOlaLogin extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height * 0.07); //Punto de inicio de la ola
    //Curva izquierda
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.20,
      size.width * 0.50, size.height * 0.10, //Se dibuja una curva suave hacia el centro
    );
    path.quadraticBezierTo(//Curva hacia la derecha
      size.width * 0.80, size.height * 0.005,
      size.width, size.height * 0.05,
    );
    path.lineTo(size.width, size.height); //Bajo por el lado derecho
    path.lineTo(0, size.height); //Esquina superior derecha
    path.close();                //Cierro el path
    return path;                 //Devuelvo la forma resultante
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
