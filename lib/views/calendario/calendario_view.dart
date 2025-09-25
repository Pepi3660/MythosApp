import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioView extends StatefulWidget {
  const CalendarioView({super.key});
  @override
  State<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends State<CalendarioView> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  // Mock de eventos (puedes migrarlo a un servicio luego)
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      'Fiesta patronal en León',
      'Feria del Maíz – Sébaco',
    ],
  };

  List<String> _getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _events[key] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
              children: [
                TableCalendar<String>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focused,
                  eventLoader: _getEventsForDay,
                  selectedDayPredicate: (d) =>
                      _selected != null &&
                      d.year == _selected!.year &&
                      d.month == _selected!.month &&
                      d.day == _selected!.day,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selected = selected;
                      _focused = focused;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: cs.tertiary.withValues(alpha: .35),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: cs.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
                const SizedBox(height: 16),
                Text('Eventos', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ..._getEventsForDay(_selected ?? DateTime.now()).map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.open_in_new),
                          tooltip: 'Detalles',
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Header superpuesto (volver + título)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Material(
                    color: cs.surface.withValues(alpha: .92),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: 'Volver',
                      onPressed: () {
                        final r = GoRouter.of(context);
                        if (r.canPop()) context.pop(); else context.go('/home');
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      'Calendario cultural',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}