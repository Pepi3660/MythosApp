// Pantalla principal del módulo: calendario + lista de eventos del día.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/eventos.dart';
import '../../viewmodels/calendarioViewModel.dart';
import '../../widgets/EventoCard.dart';
import 'EventoDetalle.dart';
import 'NuevoEvento.dart';

class CalendarioViews extends StatelessWidget {
  const CalendarioViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarioViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            //Estilo de appTheme
            title: Text('Calendario de Eventos'),
          ),
          body: RefreshIndicator(
            
            // Pull-to-refresh recarga el mes visible
            onRefresh: () => vm.cargarMes(vm.focusedDay),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CalendarWidget(
                  onMonthChanged: (d) => vm.cargarMes(d),
                  onDaySelected: (day, _) => vm.seleccionarDia(day),
                  eventLoader: (d) => vm.eventosParaDia(d),
                  selectedDay: vm.selectedDay,
                  focusedDay: vm.focusedDay,
                ),
                const SizedBox(height: 16),

                // Estado de carga / error / lista de eventos
                if (vm.loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                else if (vm.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(vm.error!, style: Theme.of(context).textTheme.bodyLarge),
                  )
                else
                  ...vm.eventosSeleccionados.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EventoCard(
                        evento: e,
                        // Navega a la vista de detalles
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventoDetallePage(eventoId: e.idE),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.small(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AgregarEventoPage())),
              child: const Icon(Icons.add),
            ),
        );
      },
    );
  }
}

/// Encapsula el `TableCalendar` con estilos acordes al AppTheme.
class _CalendarWidget extends StatelessWidget {
  final Function(DateTime) onMonthChanged; // callback al cambiar página/mes
  final Function(DateTime, DateTime) onDaySelected; // callback al tocar un día
  final List<Evento> Function(DateTime) eventLoader; // eventos por día
  final DateTime? selectedDay; // día seleccionado
  final DateTime focusedDay; // día foco (mes visible)

  const _CalendarWidget({
    required this.onMonthChanged,
    required this.onDaySelected,
    required this.eventLoader,
    required this.selectedDay,
    required this.focusedDay,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar<Evento>(
          // Rango amplio de calendario
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: focusedDay,
          locale: Localizations.localeOf(context).languageCode,
          availableGestures: AvailableGestures.horizontalSwipe,
          // Encabezado (ocultamos el botón de formato)
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.headlineMedium!,
            leftChevronIcon: Icon(Icons.chevron_left, color: scheme.primary),
            rightChevronIcon: Icon(Icons.chevron_right, color: scheme.primary),
          ),
          // Estilos de celdas y marcadores
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: scheme.tertiary.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: scheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          // Cómo saber si una fecha está seleccionada
          selectedDayPredicate: (d) =>
              selectedDay != null &&
              d.year == selectedDay!.year &&
              d.month == selectedDay!.month &&
              d.day == selectedDay!.day,
          // Callbacks
          onDaySelected: (sd, fd) => onDaySelected(sd, fd),
          onPageChanged: (fd) => onMonthChanged(fd),
          // Proveedor de eventos por día (para puntos/marcadores)
          eventLoader: (d) => eventLoader(d),
          // Personalización de los indicadores
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              // Dibuja puntitos (máx. 3) bajo el día
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Wrap(
                    spacing: 3,
                    runSpacing: -6,
                    children: List.generate(
                      events.length.clamp(0, 3),
                      (_) => Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
