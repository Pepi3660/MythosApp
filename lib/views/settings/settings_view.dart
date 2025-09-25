import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/permission_service.dart';
import '../../utils/responsive_utils.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _darkMode = false;
  String _selectedLanguage = 'Español';
  String _selectedTheme = 'Automático';
  
  final List<String> _languages = ['Español', 'English', 'Miskito'];
  final List<String> _themes = ['Claro', 'Oscuro', 'Automático'];
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _initializePermissions();
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

  Future<void> _initializePermissions() async {
    await _permissionService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Apariencia
          _buildSection(
            context,
            'Apariencia',
            Icons.palette_outlined,
            [
              _buildThemeSelector(context),
              _buildLanguageSelector(context),
              _buildDarkModeToggle(context),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sección de Permisos
          _buildSection(
            context,
            'Permisos del Dispositivo',
            Icons.security_outlined,
            [
              _buildPermissionItem(
                context,
                'Ubicación',
                'Necesario para el mapa interactivo',
                Icons.location_on_outlined,
                _permissionService.hasLocationPermission,
                (value) => _togglePermission(Permission.location, value),
              ),
              _buildPermissionItem(
                context,
                'Cámara',
                'Para capturar fotos de relatos',
                Icons.camera_alt_outlined,
                _permissionService.hasCameraPermission,
                (value) => _togglePermission(Permission.camera, value),
              ),
              _buildPermissionItem(
                context,
                'Almacenamiento',
                'Para guardar contenido multimedia',
                Icons.storage_outlined,
                _permissionService.hasStoragePermission,
                (value) => _togglePermission(Permission.storage, value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sección de Notificaciones
          _buildSection(
            context,
            'Notificaciones',
            Icons.notifications_outlined,
            [
              _buildNotificationToggle(
                context,
                'Notificaciones Generales',
                'Recibir todas las notificaciones',
                _permissionService.hasNotificationPermission,
                (value) => _togglePermission(Permission.notification, value),
              ),
              _buildNotificationToggle(
                context,
                'Nuevos Relatos',
                'Cuando se publiquen nuevos relatos',
                true,
                (value) {},
              ),
              _buildNotificationToggle(
                context,
                'Eventos Culturales',
                'Recordatorios de eventos próximos',
                true,
                (value) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sección de Privacidad
          _buildSection(
            context,
            'Privacidad y Datos',
            Icons.privacy_tip_outlined,
            [
              _buildPrivacyItem(
                context,
                'Política de Privacidad',
                'Lee nuestra política de privacidad',
                Icons.description_outlined,
                () => _showPrivacyPolicy(context),
              ),
              _buildPrivacyItem(
                context,
                'Términos de Uso',
                'Consulta los términos de uso',
                Icons.gavel_outlined,
                () => _showTermsOfUse(context),
              ),
              _buildPrivacyItem(
                context,
                'Gestionar Datos',
                'Controla tu información personal',
                Icons.manage_accounts_outlined,
                () => _showDataManagement(context),
              ),
              _buildPrivacyItem(
                context,
                'Eliminar Cuenta',
                'Eliminar permanentemente tu cuenta',
                Icons.delete_forever_outlined,
                () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sección de Información
          _buildSection(
            context,
            'Información de la App',
            Icons.info_outlined,
            [
              _buildInfoItem(context, 'Versión', '1.0.0'),
              _buildInfoItem(context, 'Desarrollado por', 'Equipo MythosApp'),
              _buildInfoItem(context, 'Contacto', 'info@mythosapp.ni'),
            ],
          ),
          const SizedBox(height: 32),
          
          // Botón de cerrar sesión
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: scheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: scheme.primary,
      ),
      title: Text(
        'Tema',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _selectedTheme,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: scheme.onSurface.withOpacity(0.4),
      ),
      onTap: () => _showThemeSelector(context),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        Icons.language_outlined,
        color: scheme.primary,
      ),
      title: Text(
        'Idioma',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _selectedLanguage,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: scheme.onSurface.withOpacity(0.4),
      ),
      onTap: () => _showLanguageSelector(context),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return SwitchListTile(
      secondary: Icon(
        Icons.dark_mode_outlined,
        color: scheme.primary,
      ),
      title: Text(
        'Modo Oscuro',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Activar tema oscuro manualmente',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: _darkMode,
      onChanged: (value) {
        setState(() {
          _darkMode = value;
        });
      },
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isEnabled,
    Function(bool) onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: scheme.primary,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: isEnabled,
      onChanged: onChanged,
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    String title,
    String subtitle,
    bool isEnabled,
    Function(bool) onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return SwitchListTile(
      secondary: Icon(
        Icons.notifications_outlined,
        color: scheme.primary,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: isEnabled,
      onChanged: onChanged,
    );
  }

  Widget _buildPrivacyItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : scheme.primary,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: scheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _togglePermission(Permission permission, bool enable) async {
    if (enable) {
      final granted = await _permissionService.requestPermission(permission);
      
      if (!granted) {
        _showPermissionDeniedDialog(context, permission);
      }
    } else {
      // Mostrar diálogo para ir a configuraciones
      _showDisablePermissionDialog(context, permission);
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Tema',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._themes.map((theme) => ListTile(
              title: Text(
                theme,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              leading: Radio<String>(
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Idioma',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._languages.map((language) => ListTile(
              title: Text(
                language,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              leading: Radio<String>(
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context, Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Permiso Denegado',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Para usar esta función, necesitas habilitar el permiso en la configuración del dispositivo.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Configuración',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisablePermissionDialog(BuildContext context, Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Desactivar Permiso',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Para desactivar este permiso, ve a la configuración del dispositivo.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Configuración',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Implementar vista de política de privacidad
  }

  void _showTermsOfUse(BuildContext context) {
    // Implementar vista de términos de uso
  }

  void _showDataManagement(BuildContext context) {
    // Implementar gestión de datos
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Cuenta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Esta acción eliminará permanentemente tu cuenta y todos tus datos. ¿Estás seguro?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar eliminación de cuenta
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar cierre de sesión
            },
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}