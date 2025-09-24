//El presente documento almacena la vista de verificacion 
//del otp

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/botonPrincipal.dart';

class OtpVerificationView extends StatefulWidget {
  final String name; // nombre capturado en el registro
  final String email; // email capturado en el registro
  final String password; // password capturado en el registro
  final String? prefilledOtp; // Codigo

  const OtpVerificationView({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    this.prefilledOtp,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  // Colores locales solicitados
  static const darkOliveGreen = Color(0xFF326430);
  static const fernGreen = Color(0xFF457A43);
  static const fieldFill = Color(0xFFD7E6DB);

  // Letra fija del OTP
  static const fixedLetter = 'M';

  // Controlador para los 4 dígitos
  final _digitsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si viene un OTP prellenado, autocompleta los dígitos
    final otp = widget.prefilledOtp;
    if (otp != null &&
        otp.length == 5 &&
        otp.toUpperCase().startsWith(fixedLetter)) {
      _digitsCtrl.text = otp.substring(1);
    }
  }

  @override
  void dispose() {
    _digitsCtrl.dispose();
    super.dispose();
  }

  // Construye el código completo 'M1234'
  String _fullCode() => '$fixedLetter${_digitsCtrl.text.trim()}';

  // Solo valida si el usuario escribió 4 dígitos
  Future<void> _onVerifyPressed(BuildContext context) async {
    final digits = _digitsCtrl.text.trim();
    if (digits.length != 4 || int.tryParse(digits) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 4 dígitos del código')),
      );
      return;
    }

    await _onVerifyAndRegister(context);
  }

  // Verifica el OTP y registra al usuario
  Future<void> _onVerifyAndRegister(BuildContext context) async {
    final vm = context.read<AuthViewModel>();
    final fullCode = _fullCode(); // 'M1234'

    final okOtp = await vm.verifyLocalOtp(fullCode);
    if (!mounted) return;

    if (!okOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(vm.errorMessage ?? 'Código inválido o expirado')),
      );
      return;
    }

    // OTP correcto → Registrar usuario con los datos recibidos
    final okRegister = await vm.registerEmail(
      name: widget.name,
      email: widget.email,
      password: widget.password,
    );
    if (!mounted) return;

    if (okRegister) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cuenta verificada y creada con éxito')),
      );
      context.go('/relatos');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(vm.errorMessage ??
                'No fue posible crear la cuenta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        //title: const Text('Verificar código'),
        backgroundColor: Colors.white,
        foregroundColor: darkOliveGreen,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa el código enviado a tu correo',
                style: TextStyle(
                  color: darkOliveGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Código de verificación (M + 4 dígitos)',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Caja de la letra fija + campo de 4 dígitos
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: fernGreen, width: 1),
                    ),
                    child: const Text(
                      fixedLetter,
                      style: TextStyle(
                        color: darkOliveGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: _digitsCtrl,
                      maxLength: 4,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: darkOliveGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '1234',
                        hintStyle: TextStyle(color: darkOliveGreen),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius:
                              BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _onVerifyPressed(context),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              PrimaryButton(
                label: 'Verificar',
                loading: vm.isLoading,
                onPressed: () => _onVerifyPressed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
