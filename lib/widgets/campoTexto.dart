//En el presente archivo se almacena la configuracion
//del los cuadros de textos redondeados reutilizables
//utilizado tanto en el inicio de sesion como en el registro

import 'package:flutter/material.dart';   //Libreria que permite el uso de TextFormField e íconos

class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;                 //Controlador del campo
  final String hint;                                      //Texto de sugerencia
  final IconData icon;                                    //Ícono inicial
  final TextInputType keyboardType;                       //Tipo de teclado
  final String? Function(String?)? validator;             //Validador
  final bool obscure;                                     //Ocultador de texto
  final VoidCallback? onToggleVisibility;                 //Acción para alternar visibilidad

  //Inicializacion de componentes
  const RoundedTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscure = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    //Colores locales utilizados
    const darkOliveGreen = Color(0xFF326430);
    const lightGreen = Color(0xFFD7E6DB);

    return TextFormField(
      controller: controller,                              //Vinculacion el controlador
      keyboardType: keyboardType,                          //Asignacion tipo de teclado
      obscureText: obscure,                                //Activo/Desactivo ocultamiento
      validator: validator,                                //Asignacion del validador
      autovalidateMode: AutovalidateMode.onUserInteraction,//Validacion tras interacción
      style: const TextStyle(color: darkOliveGreen, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,                                    //Sugerencia dentro del campo
        hintStyle: const TextStyle(
          color: darkOliveGreen,
          fontSize: 16,
        ),
        filled: true, fillColor: lightGreen,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: darkOliveGreen),
        suffixIcon: onToggleVisibility != null             //Si tengo toggle, muestro ícono de ojo
            ? IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                    color: darkOliveGreen),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
