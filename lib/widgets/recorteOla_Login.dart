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
      ..moveTo(0, 0);       //Inicio desde la izquierda y bajo al 70% alto
    path.quadraticBezierTo(                               //Se dibuja una curva suave hacia el centro
      size.width * 0.15, size.height * 0.20,
      size.width * 0.48, size.height * 0.15,
    );
    path.quadraticBezierTo(                               //Completo la curva hacia la derecha
      size.width * 0.85, size.height * 0.05,
      size.width, 0,
    );
    path.lineTo(size.width, size.height);        // Bajo por el lado derecho
    path.lineTo(0, size.height);                        //Subo recto hasta la esquina superior derecha
    path.close();                                         //Cierro el path
    return path;                                          //Devuelvo la forma resultante
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
