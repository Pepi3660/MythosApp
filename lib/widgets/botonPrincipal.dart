//En este archivo se almacena la configuracion
//del boton principal utilizado para guardar el inicio de sesion y el registro
//con el fin de reutilizar el componente

import 'package:flutter/material.dart';                   //Libreria que permite usar ElevatedButton

class PrimaryButton extends StatelessWidget {
  final String label;                                     //Texto del botón
  final VoidCallback onPressed;                           //Acción al presionar
  final bool loading;                                     //Flag de carga

    //Inicializacion de las variables
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    //Definicion de colores
    const fernGreen = Color(0xFF457A43);

    return SizedBox(
      width: double.infinity,                              //Ocupo todo el ancho disponible
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,             //Desactivo si está en loading
        style: ElevatedButton.styleFrom(
          backgroundColor: fernGreen,                      //Fondo con Fern Green (color)
          foregroundColor: Colors.white,                   //Texto en blanco
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: loading                                     //Muestro loader si está cargando
            ? const SizedBox(
                height: 24, width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
