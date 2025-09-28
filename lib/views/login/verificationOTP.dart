//El presente documento almacena la vista de verificacion 
//del otp

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/botonPrincipal.dart';

class OtpVerificationView extends StatefulWidget {
  final String name;            // nombre capturado en el registro
  final String email;           // email capturado en el registro
  final String password;        // password capturado en el registro
  final String? prefilledOtp;   // OTP completo opcional, ej: 'M1234'

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
  // Letra fija del OTP (se mantiene la lógica original)
  static const String fixedLetter = 'M';

  // Control "lógico" que guarda los 4 dígitos unidos (no visible).
  final TextEditingController _digitsCtrl = TextEditingController();

  // 4 controladores y 4 focos para las casillas individuales
  final List<TextEditingController> _boxCtrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _boxFocus = List.generate(4, (_) => FocusNode());

  // Timer 5:00 estilo mockup
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();

    // Prefill si viene un OTP (ej: 'M1234')
    final otp = widget.prefilledOtp;
    if (otp != null && otp.length == 5 && otp.toUpperCase().startsWith(fixedLetter)) {
      final d = otp.substring(1);
      for (int i = 0; i < 4; i++) {
        _boxCtrls[i].text = d[i];
      }
      _syncDigitsCtrl();
    }

    // Iniciamos timer de 5:00
    _startTimer();

    // Listeners para mantener _digitsCtrl actualizado con las 4 casillas
    for (int i = 0; i < 4; i++) {
      _boxCtrls[i].addListener(_syncDigitsCtrl);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _digitsCtrl.dispose();
    for (final c in _boxCtrls) c.dispose();
    for (final f in _boxFocus) f.dispose();
    super.dispose();
  }

  // Une los 4 dígitos en _digitsCtrl
  void _syncDigitsCtrl() {
    _digitsCtrl.text = _boxCtrls.map((c) => c.text).join();
  }

  // Inicia o reinicia el contador a 5:00
  void _startTimer() {
    _timer?.cancel();
    setState(() => _remaining = const Duration(minutes: 5));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        t.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining = Duration(seconds: _remaining.inSeconds - 1));
      }
    });
  }

  // Formato mm:ss
  String get _mmss {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Enmascara el correo
  String get _maskedEmail {
    final email = widget.email.trim();
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 2) return '${name[0]}***@${parts[1]}';
    final visible = name.substring(0, 2);
    return '$visible*****@${parts[1]}';
  }

  // Construye el código completo
  String _fullCode() => '$fixedLetter${_digitsCtrl.text.trim()}';

  // Verifica entrada y llama al flujo de verificación/registro
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

  // Verifica OTP local y registra
  Future<void> _onVerifyAndRegister(BuildContext context) async {
    final vm = context.read<AuthViewModel>();
    final fullCode = _fullCode(); // 'M1234'

    final okOtp = await vm.verifyLocalOtp(fullCode);
    if (!mounted) return;

    if (!okOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Código inválido o expirado')),
      );
      return;
    }

    // OTP correcto + Registrar usuario con los datos recibidos
    final okRegister = await vm.registerEmail(
      name: widget.name,
      email: widget.email,
      password: widget.password,
    );
    if (!mounted) return;

    if (okRegister) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta verificada y creada con éxito')),
      );
      context.go('/app');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'No fue posible crear la cuenta')),
      );
    }
  }

  // Reenvío de código: reusa el flujo de sendMagicLink y resetea timer
  Future<void> _resendCode(BuildContext context) async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.sendEmail(widget.email);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un nuevo código')),
      );
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'No se pudo reenviar el código')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        title: Text('Verificación', style: tt.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título grande estilo mockup
              Text(
                'Ingresa tu  \nCodigo de verificación',
                style: tt.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // Fila de casillas: 4 dígitos + letra fija a la derecha
              Row(
                children: [
                // Letra fija (M)
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      fixedLetter,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  for (int i = 0; i < 4; i++) ...[
                    _OtpBox(
                      controller: _boxCtrls[i],
                      focusNode: _boxFocus[i],
                      onChanged: (val) {
                        // Acepta solo un dígito y salta al siguiente
                        if (val.length > 1) {
                          _boxCtrls[i].text = val[val.length - 1];
                          _boxCtrls[i].selection = TextSelection.fromPosition(
                              TextPosition(offset: _boxCtrls[i].text.length));
                        }
                        if (val.isNotEmpty && i < 3) {
                          _boxFocus[i + 1].requestFocus();
                        }
                        if (val.isEmpty && i > 0) {
                          _boxFocus[i - 1].requestFocus();
                        }
                      },
                      onSubmitted: (_) {
                        if (i < 3) {
                          _boxFocus[i + 1].requestFocus();
                        } else {
                          _onVerifyPressed(context);
                        }
                      },
                    ),
                    if (i != 3) const SizedBox(width: 12),
                  ],
                ],
              ),

              const SizedBox(height: 18),

              // Texto informativo con email enmascarado
              Text(
                'Hemos enviado tu codigo a $_maskedEmail.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),

            // Reenviar
            GestureDetector(
              onTap: _remaining == Duration.zero ? () => _resendCode(context) : null,
              child: Text(
                _remaining == Duration.zero
                    ? "¿No has recibido tu código? Reenviar"
                    : "Podrás reenviar en $_mmss",
                style: tt.bodyMedium?.copyWith(
                  color: _remaining == Duration.zero
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

              const Spacer(),

              // Botón Verificar
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

/// Caja de 1 dígito con estilo del AppTheme
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: 56,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}