import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/relato.dart';
import '../../viewmodels/relatos_vm.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    //Usuario Firebase
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email ?? 'Usuario');
    final photoUrl = user?.photoURL;

    //Mis relatos (desde VM)
    final vm = context.watch<RelatosVM>();
    final myRelatos = vm.relatos.where((r) => _isMine(r, user)).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con perfil del usuario
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: scheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.primary,
                      scheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      //Avatar del usuario (foto Firebase o icono por defecto)
                      if (photoUrl != null && photoUrl.isNotEmpty)
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: scheme.onPrimary,
                          child: CircleAvatar(
                            radius: 37,
                            backgroundImage: NetworkImage(photoUrl),
                            backgroundColor: scheme.secondary,
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.onPrimary,
                              width: 3,
                            ),
                            color: scheme.secondary,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: scheme.onSecondary,
                          ),
                        ),

                      const SizedBox(height: 12),

                      //Nombre del usuario (Firebase)
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimary,
                        ),
                      ),
                      Text(
                        'Guardiana/o de tradiciones',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: scheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _showSettingsBottomSheet(context);
                },
              ),
            ],
          ),
          
          // Contenido del perfil
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas del usuario (relatos compartidos reales; lo demás provisional)
                  _buildStatsSection(context, myRelatosCount: myRelatos.length),
                  const SizedBox(height: 24),
                  
                  // Mis contribuciones (lista real de mis relatos, o mensaje vacío)
                  _buildContributionsSection(
                      context,
                      allRelatos: vm.relatos, // la lista completa de relatos
                      currentUserId: user!.uid,
                    ),
                  const SizedBox(height: 24),
                  
                  // Opciones del perfil (provisional)
                  _buildProfileOptions(context),
                  const SizedBox(height: 24),
                  
                  // Información adicional (provisional)
                  _buildAdditionalInfo(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isMine(Relato r, User? user) {
    if (user == null) return false;
    // r.idU es un DocumentReference a 'usuarios/{uid}'
    final ref = r.idU;
    if (ref == null) return false;
    return ref.id == user.uid; // .id del DocumentReference es el UID
  }

  // SECCIONES
  Widget _buildStatsSection(BuildContext context, {required int myRelatosCount}) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Estadísticas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    '$myRelatosCount',           // relatos del usuario
                    'Relatos\nCompartidos',
                    Icons.menu_book,
                    scheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '8',                          // provisional
                    'Eventos\nCreados',
                    Icons.event,
                    scheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '156',                        // provisional
                    'Puntos de\nCultura',
                    Icons.star,
                    scheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//Relatos
  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

    Widget _buildContributionsSection(
      BuildContext context, {
      required List<Relato> allRelatos,
      required String currentUserId,
    }) {
      final scheme = Theme.of(context).colorScheme;
      final locale = Localizations.localeOf(context).languageCode;

      // Filtrar relatos creados por el usuario actual
      final myRelatos = allRelatos.where((r) {
        // Si guardaste como UID string:
        return r.idU == currentUserId;

        // O si usas DocumentReference:
        // return r.userRef.id == currentUserId;
      }).toList();

      if (myRelatos.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aún no has publicado',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: scheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        );
      }

      final sorted = [...myRelatos]
        ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      final recent = sorted.take(3).toList();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Contribuciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/relatos?user=$currentUserId');
                    },
                    child: Text(
                      'Ver todas',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              for (final r in recent)
                _buildContributionItem(
                  context,
                  _titleFromContent(r),
                  r.tipoP == 'texto' ? 'Relato de texto' : 'Relato con imagen',
                  r.tipoP == 'texto'
                      ? Icons.menu_book_outlined
                      : Icons.image_outlined,
                  DateFormat.yMMMd(locale).add_Hm().format(r.fechaCreacion),
                ),
            ],
          ),
        ),
      );
    }

  // Título rápido derivado del contenido (si no tienes campo 'titulo')
  String _titleFromContent(Relato r) {
    if (r.tipoP == 'imagen') return 'Relato con imagen';
    final t = r.contenido.trim();
    if (t.isEmpty) return 'Relato de texto';
    final firstBreak = t.indexOf('\n');
    final firstDot = t.indexOf('.');
    int cut = t.length;
    if (firstDot > 0) cut = firstDot + 1;
    if (firstBreak > 0) cut = cut < firstBreak ? cut : firstBreak;
    final head = t.substring(0, cut).trim();
    return head.length <= 80 ? head : '${head.substring(0, 80)}…';
  }

  Widget _buildContributionItem(BuildContext context, String title, String subtitle, IconData icon, String time) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: scheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: scheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Column(
        children: [
          _buildOptionItem(
            context,
            'Editar Perfil',
            'Actualiza tu información personal',
            Icons.edit_outlined,
            () {},
          ),
          _buildOptionItem(
            context,
            'Mis Favoritos',
            'Relatos y eventos guardados',
            Icons.favorite_outline,
            () {},
          ),
          _buildOptionItem(
            context,
            'Historial',
            'Tu actividad en la aplicación',
            Icons.history_outlined,
            () {},
          ),
          _buildOptionItem(
            context,
            'Configuración',
            'Preferencias y privacidad',
            Icons.settings_outlined,
            () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool showDivider = true,
    bool isDestructive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = isDestructive ? scheme.error : scheme.primary;
    final titleColor = isDestructive ? scheme.error : scheme.onSurface;
    
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: scheme.onSurface.withOpacity(0.4)),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(height: 1, color: scheme.outlineVariant),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre MythosApp',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Preservando la memoria viva de Nicaragua. Cada relato, cada tradición, cada historia cuenta para mantener viva nuestra cultura.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(
                      'Acerca de',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(
                      'Soporte',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SettingsBottomSheet(),
    );
  }
}

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configuración',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSettingSection(
                  context,
                  'Apariencia',
                  [
                    _buildSettingItem(context, 'Tema', 'Claro, Oscuro o Automático', Icons.palette_outlined, () {}),
                    _buildSettingItem(context, 'Idioma', 'Español', Icons.language_outlined, () {}),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingSection(
                  context,
                  'Privacidad',
                  [
                    _buildSettingItem(context, 'Permisos', 'Gestionar permisos de la app', Icons.security_outlined, () {}),
                    _buildSettingItem(context, 'Datos y Privacidad', 'Control de información personal', Icons.privacy_tip_outlined, () {}),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingSection(
                  context,
                  'Notificaciones',
                  [
                    _buildSettingItem(context, 'Nuevos Relatos', 'Recibir notificaciones', Icons.notifications_outlined, () {}),
                    _buildSettingItem(context, 'Eventos Culturales', 'Recordatorios de eventos', Icons.event_note_outlined, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(BuildContext context, String title, List<Widget> items) {
    final scheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: scheme.onSurface.withOpacity(0.4)),
      onTap: onTap,
    );
  }
}