//Vista de registro de una nueva cuenta

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/botonPrincipal.dart';
import '../../widgets/campoTexto.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  //Clave del formulario y controladores de texto
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  //Colores locales
  static const darkOliveGreen = Color(0xFF326430);
  static const fernGreen      = Color(0xFF457A43);
  static const fieldFill      = Color(0xFFD7E6DB);

  //Validador rápido para dibujar un “check” de email válido
  bool get _isEmailValid {
    final v = _emailCtrl.text.trim();
    if (v.isEmpty) return false;
    return RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$').hasMatch(v); //Formato correcto del correo
  }

  //Estado de la vista si el otp ya fue completado  o no
  bool _OTPVer = false;

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios del email para refrescar el “check” de validación
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Obtenemos el ViewModel para invocar registro y Google
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: true, //Evita que el teclado tape los campos
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              Text(
                'Bienvenido a Mythos',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: darkOliveGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Crea tu nueva cuenta',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              //Formulario de registro
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    RoundedTextField(
                      controller: _nameCtrl,
                      hint: 'Nombre de Usuario',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nombre requerido' : null,
                    ),
                    const SizedBox(height: 20),

                    // Email
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        RoundedTextField(
                          controller: _emailCtrl,
                          hint: 'Correo electrónico',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Correo requerido';
                            return _isEmailValid ? null : 'Correo inválido';
                          },
                        ),
                        AnimatedOpacity(
                          opacity: _isEmailValid ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(Icons.check_circle, color: fernGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    //Contraseña
                    RoundedTextField(
                      controller: _passCtrl,
                      hint: 'Contraseña',
                      icon: Icons.lock_outline_rounded,
                      obscure: vm.obscure,
                      onToggleVisibility: vm.toggleObscure,
                      validator: (v) =>
                          (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                    ),

                    const SizedBox(height: 40),
                    //Flujo de registsro con OTP
                    //Envio del OTP
                    PrimaryButton(
                      label: 'Enviar código al correo',
                      loading: vm.isLoading,
                      onPressed: () async {
                        if (!_isEmailValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingresa un correo válido')),
                          );
                          return;
                        }
                        final ok = await vm.sendMagicLink(_emailCtrl.text);
                        if (!mounted) return;

                        if (ok) {
                          setState(() => _OTPVer = true); //Habilita el boton de registro
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hemos enviado un enlace a tu correo.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(vm.errorMessage ?? 'No se pudo enviar el enlace')),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    //Botón de Registro
                     // if (_OTPVer)
                      PrimaryButton(
                        label: 'Registrarse',
                        loading: vm.isLoading,
                        onPressed: () async {
                          //Validar formulario
                          if (!_formKey.currentState!.validate()) return;
                          // con correo+password (Auth.signUp), debemos cerrar esa sesión temporal.
                          try {
                            await FirebaseAuth.instance.signOut();
                          } catch (_) {}
                          
                          //Registrar con correo/contraseña a través del ViewModel
                          final ok = await vm.registerEmail(
                            name: _nameCtrl.text,
                            email: _emailCtrl.text,
                            password: _passCtrl.text,
                          );

                          if (!mounted) return;

                          //Mostrar resultado y navegar a /relatos
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cuenta creada con éxito')),
                            );
                            context.go('/relatos');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(vm.errorMessage ?? 'No fue posible crear la cuenta')),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Separador
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Registrarse con:',
                      style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: Colors.black12)),
                ],
              ),

              const SizedBox(height: 30),

              //Botón social: SOLO Google
              _SocialCircle(
                icon: Icons.g_mobiledata,
                onTap: vm.isLoading
                    ? null
                    : () async {
                        // Iniciar sesión / registro con Google
                        final ok = await vm.signInOrRegisterWithGoogle();

                        if (!mounted) return;

                        //Mostrar resultado y navegar a /relatos si fue exitoso
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inicio con Google exitoso')),
                          );
                          context.go('/relatos');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(vm.errorMessage ?? 'No fue posible usar Google')),
                          );
                        }
                      },
              ),

              const SizedBox(height: 30),

              // Footer: “ya tienes cuenta”
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes una cuenta? ',
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(), // vuelve al login
                    child: Text(
                      'Iniciar Sesion',
                      style: GoogleFonts.poppins(
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
      ),
    );
  }
}

/// Botón social circular simple
class _SocialCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _SocialCircle({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // si es null, queda deshabilitado
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: const Icon(Icons.g_mobiledata, size: 32, color: _RegisterViewState.darkOliveGreen),
      ),
    );
  }
}
