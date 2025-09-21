import 'package:flutter/material.dart';

class MythosNavItem {
  final IconData icon;
  final String label;
  const MythosNavItem({required this.icon, required this.label});
}

class MythosNavBar extends StatelessWidget {
  final int index;
  final void Function(int) onTap;
  final List<MythosNavItem> items;
  final Color? color;
  final Color? buttonBackgroundColor;
  final Color? backgroundColor;
  final double height;

  const MythosNavBar({
    super.key,
    this.index = 0,
    required this.onTap,
    required this.items,
    this.color,
    this.buttonBackgroundColor,
    this.backgroundColor,
    this.height = 75.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final navBarColor = color ?? cs.primary;
    final bgColor = backgroundColor ?? cs.surface;
    final buttonBgColor = buttonBackgroundColor ?? Colors.white;
    
    return Container(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Fondo de la pantalla
          Container(
            height: height,
            color: bgColor,
          ),
          // Fondo simple
          Container(
            height: height,
            color: navBarColor,
          ),
          // Items de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == index;
              return _Item(
                item: items[i],
                selected: selected,
                buttonBackgroundColor: buttonBgColor,
                onTap: () => onTap(i),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final MythosNavItem item;
  final bool selected;
  final Color buttonBackgroundColor;
  final VoidCallback onTap;

  const _Item({
    required this.item,
    required this.selected,
    required this.buttonBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: selected ? buttonBackgroundColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(selected ? 12 : 8),
                child: Icon(
                  item.icon,
                  color: selected ? cs.primary : cs.onPrimary,
                  size: 30,
                ),
              ),
              if (!selected) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
