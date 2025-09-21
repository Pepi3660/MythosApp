import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Estado de permisos
  final Map<Permission, bool> _permissionStatus = {};
  final List<VoidCallback> _listeners = [];

  // Getters para verificar permisos específicos
  bool get hasLocationPermission => _permissionStatus[Permission.location] ?? false;
  bool get hasCameraPermission => _permissionStatus[Permission.camera] ?? false;
  bool get hasStoragePermission => _permissionStatus[Permission.storage] ?? false;
  bool get hasNotificationPermission => _permissionStatus[Permission.notification] ?? false;

  // Inicializar el servicio
  Future<void> initialize() async {
    await _checkAllPermissions();
  }

  // Verificar todos los permisos
  Future<void> _checkAllPermissions() async {
    final permissions = [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      _permissionStatus[permission] = status.isGranted;
    }
    _notifyListeners();
  }

  // Solicitar un permiso específico
  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    final isGranted = status.isGranted;
    _permissionStatus[permission] = isGranted;
    _notifyListeners();
    return isGranted;
  }

  // Verificar si una función requiere permisos
  bool canUseFeature(String featureName) {
    switch (featureName) {
      case 'mapa':
        return hasLocationPermission;
      case 'camera_relatos':
        return hasCameraPermission;
      case 'save_content':
        return hasStoragePermission;
      case 'notifications':
        return hasNotificationPermission;
      case 'full_app':
        return hasLocationPermission && hasCameraPermission && hasStoragePermission;
      default:
        return true;
    }
  }

  // Obtener mensaje de permiso requerido
  String getPermissionMessage(String featureName) {
    switch (featureName) {
      case 'mapa':
        return 'Se requiere permiso de ubicación para usar el mapa interactivo';
      case 'camera_relatos':
        return 'Se requiere permiso de cámara para capturar fotos en los relatos';
      case 'save_content':
        return 'Se requiere permiso de almacenamiento para guardar contenido';
      case 'notifications':
        return 'Se requiere permiso de notificaciones para recibir alertas';
      case 'full_app':
        return 'Se requieren todos los permisos para usar la aplicación completa';
      default:
        return 'Se requieren permisos adicionales para esta función';
    }
  }

  // Mostrar diálogo de permiso requerido
  void showPermissionDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: Text(getPermissionMessage(featureName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissionForFeature(featureName);
            },
            child: const Text('Otorgar Permiso'),
          ),
        ],
      ),
    );
  }

  // Solicitar permiso para una función específica
  Future<void> _requestPermissionForFeature(String featureName) async {
    switch (featureName) {
      case 'mapa':
        await requestPermission(Permission.location);
        break;
      case 'camera_relatos':
        await requestPermission(Permission.camera);
        break;
      case 'save_content':
        await requestPermission(Permission.storage);
        break;
      case 'notifications':
        await requestPermission(Permission.notification);
        break;
      case 'full_app':
        await requestPermission(Permission.location);
        await requestPermission(Permission.camera);
        await requestPermission(Permission.storage);
        break;
    }
  }

  // Agregar listener para cambios de permisos
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remover listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notificar a los listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Verificar si todos los permisos críticos están otorgados
  bool get hasAllCriticalPermissions {
    return hasLocationPermission && hasCameraPermission && hasStoragePermission;
  }

  // Obtener lista de permisos faltantes
  List<String> get missingPermissions {
    final missing = <String>[];
    if (!hasLocationPermission) missing.add('Ubicación');
    if (!hasCameraPermission) missing.add('Cámara');
    if (!hasStoragePermission) missing.add('Almacenamiento');
    if (!hasNotificationPermission) missing.add('Notificaciones');
    return missing;
  }
}