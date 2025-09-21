import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../utils/responsive_utils.dart';

class PermissionGuard extends StatefulWidget {
  final Widget child;
  final String featureName;
  final String? customTitle;
  final String? customMessage;
  final IconData? customIcon;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.featureName,
    this.customTitle,
    this.customMessage,
    this.customIcon,
  });

  @override
  State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  final PermissionService _permissionService = PermissionService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _permissionService.addListener(_onPermissionChanged);
  }

  @override
  void dispose() {
    _permissionService.removeListener(_onPermissionChanged);
    super.dispose();
  }

  void _onPermissionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUse = _permissionService.canUseFeature(widget.featureName);
    
    if (canUse) {
      return widget.child;
    }

    return _buildPermissionBlockedScreen(context);
  }

  Widget _buildPermissionBlockedScreen(BuildContext context) {
    final responsive = ResponsiveUtils.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(responsive.wp(6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Container(
                width: responsive.dp(12),
                height: responsive.dp(12),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.customIcon ?? Icons.lock_outline,
                  size: responsive.dp(6),
                  color: cs.onErrorContainer,
                ),
              ),
              SizedBox(height: responsive.hp(4)),
              
              // Título
              Text(
                widget.customTitle ?? 'Función Bloqueada',
                style: GoogleFonts.playfairDisplay(
                  fontSize: responsive.dp(3),
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.hp(2)),
              
              // Mensaje
              Text(
                widget.customMessage ?? _permissionService.getPermissionMessage(widget.featureName),
                style: GoogleFonts.poppins(
                  fontSize: responsive.dp(1.8),
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.hp(4)),
              
              // Lista de permisos faltantes
              if (_permissionService.missingPermissions.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(responsive.wp(4)),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permisos requeridos:',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.dp(1.6),
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: responsive.hp(1)),
                      ..._permissionService.missingPermissions.map(
                        (permission) => Padding(
                          padding: EdgeInsets.symmetric(vertical: responsive.hp(0.5)),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: responsive.dp(2),
                                color: cs.primary,
                              ),
                              SizedBox(width: responsive.wp(2)),
                              Text(
                                permission,
                                style: GoogleFonts.poppins(
                                  fontSize: responsive.dp(1.4),
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.hp(4)),
              ],
              
              // Botones de acción
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: responsive.hp(2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: responsive.dp(2.5),
                              width: responsive.dp(2.5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                              ),
                            )
                          : Text(
                              'Otorgar Permisos',
                              style: GoogleFonts.poppins(
                                fontSize: responsive.dp(1.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: responsive.hp(2)),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Volver',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.dp(1.6),
                          color: cs.onSurfaceVariant,
                        ),
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

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Solicitar permisos según la función
    switch (widget.featureName) {
      case 'mapa':
        await _permissionService.requestPermission(Permission.location);
        break;
      case 'camera_relatos':
        await _permissionService.requestPermission(Permission.camera);
        break;
      case 'save_content':
        await _permissionService.requestPermission(Permission.storage);
        break;
      case 'notifications':
        await _permissionService.requestPermission(Permission.notification);
        break;
      case 'full_app':
        await _permissionService.requestPermission(Permission.location);
        await _permissionService.requestPermission(Permission.camera);
        await _permissionService.requestPermission(Permission.storage);
        break;
    }

    setState(() {
      _isLoading = false;
    });
  }
}