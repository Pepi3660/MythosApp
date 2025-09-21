//Vista de la pantalla de inicio de secion

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';         //Importo Google Fonts para un look moderno
import 'package:mythosapp/views/login/registerView.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/botonPrincipal.dart';
import '../../widgets/campoTexto.dart';
import '../../widgets/recorteOla_Login.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginScreenState();//Estado asociado
}

class _LoginScreenState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();               //Clave global para validar el formulario
  final _emailCtrl = TextEditingController();            //Controlador del campo Email
  final _passCtrl = TextEditingController();             //Controlador del campo Password

  //Controll de la altura del texto
  static const double _kWaveHeight = 260;

  @override
  void dispose() {
    _emailCtrl.dispose();                                 //Libero el controlador de Email
    _passCtrl.dispose();                                  //Libero el controlador de Password
    super.dispose();                                      //Llamo a dispose de la superclase
  }

  @override
  Widget build(BuildContext context) {
    // -> Obtengo el ViewModel
    final vm = context.watch<AuthViewModel>();

    //Colores locales
    const darkOliveGreen = Color(0xFF326430);
    const fernGreen = Color(0xFF457A43);

    return Scaffold(
      resizeToAvoidBottomInset: true,                     //Evita que el teclado tape los campos
      body: Stack(
        children: [
          //Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/FondoLogin.jpg',
              fit: BoxFit.cover,
            ),
          ),
          //Capa blanca recortada con forma de ola para el contenido
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: RecorteOlaLogin(), //Aplico el recorte creado
              child: Container(
                //Altura relativa para dejar la parte superior con la imagen
                height: MediaQuery.of(context).size.height * 0.78,
                color: Colors.white,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,

            // ✅ Calculamos la posición según el teclado
            left: 24,
            right:24,
            // top dinámico: debajo de la ola cuando no hay teclado,
            // y sube cuando aparece, pero sin invadir la imagen.
            top: () {
              final kb = MediaQuery.of(context).viewInsets.bottom;  // altura del teclado
              final baseTop = _kWaveHeight + 15;                    // bajo la ola
              final dynamicTop = (baseTop - kb).clamp(32.0, baseTop);
              return dynamicTop.toDouble();
            }(),
          //Contenido de la pantalla
          child: SafeArea(
              child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Títulos principales con Google Fonts para un look moderno
                  Text('Bienvenido de vuelta',
                      style: GoogleFonts.poppins(
                        color: darkOliveGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  Text('Inicia Sesion con tu cuenta',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 25),
                  // Formulario con validaciones
                  Form(
                    key: _formKey,                           // -> Asocio la clave para validar
                    child: Column(
                      children: [
                        // Campo de correo
                        RoundedTextField(
                          controller: _emailCtrl,            //Vinculo controlador
                          hint: 'Correo Electrónico',
                          icon: Icons.person_rounded,        //Ícono de usuario
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {                   //Validador simple de email
                            if (v == null || v.isEmpty) return 'Correo requerido';
                            final ok = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$').hasMatch(v);
                            return ok ? null : 'Correo inválido';
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo de contraseña con toggle de visibilidad
                        RoundedTextField(
                          controller: _passCtrl,             //Vinculo controlador
                          hint: 'Contraseña',
                          icon: Icons.lock_rounded,          //Ícono de candado
                          obscure: vm.obscure,               //Leo del VM si está oculto o no
                          validator: (v) {                   //Valido longitud mínima
                            if (v == null || v.length < 8) return 'Contraseña mínimo 8 caracteres';
                            return null;
                          },
                          onToggleVisibility: vm.toggleObscure, //Conecto el toggle al VM
                        ),
                        const SizedBox(height: 15),
                        // Fila: Recordarme + Olvidé contraseña
                        Row(
                          children: [
                            Checkbox(
                              value: vm.rememberMe,          //Binding al VM
                              onChanged: (v) => vm.setRemember(v ?? false), //Actualizo VM
                              side: const BorderSide(color: fernGreen),
                              checkColor: Colors.white,                      //Color del “check”
                              activeColor: fernGreen,
                            ),
                            const Text('Recuerdame'),       // Etiqueta del checkbox
                            const Spacer(),                  //Empujo el botón a la derecha
                            TextButton(
                              onPressed: () async {          //Acción para recuperar contraseña
                                final email = _emailCtrl.text;
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ingresa tu correo para recuperar')),
                                  );
                                  return;
                                }
                                final ok = await vm.reset(email); //Llamo al flujo de reset en el VM
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Te enviamos un enlace a tu correo'
                                        : vm.errorMessage ?? 'No fue posible enviar el enlace'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: fernGreen,
                              ),
                              child: const Text('¿Olvidate tu contraseña?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Botón principal de Login
                        PrimaryButton(
                          label: 'Iniciar Sesión',                    //Texto del botón
                          loading: vm.isLoading,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return; //Valido formulario
                            final ok = await vm.login(       //Llamo al método de login del VM
                              _emailCtrl.text,
                              _passCtrl.text,
                            );
                            if (!mounted) return;           //Verifico que el widget exista aún
                            if (ok) {
                              //Mensaje de login exitoso
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inicio de sesión exitoso')),
                              );
                              // Redireccion a la pantalla de relatos
                            context.go('/relatos');
                            } else {
                              // -> Muestro el error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.errorMessage ?? 'Error desconocido')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        // Pantalla de REgistro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("¿No tienes una cuenta?  "),
                            GestureDetector(
                              //Navegacion a la Pantalla de registro
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RegisterView()),
                                  );
                              },
                              child: const Text(
                                'Registrate Ahora',
                                style: TextStyle(
                                  color: fernGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
