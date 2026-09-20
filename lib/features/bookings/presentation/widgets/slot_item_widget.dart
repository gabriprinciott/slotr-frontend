import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slotr_app/l10n/app_localizations.dart';

enum SlotState { available, selected, locked, booked }

class SlotItemWidget extends StatelessWidget {
  final String time;
  final SlotState state;
  final VoidCallback? onTap;

  const SlotItemWidget({
    super.key,
    required this.time,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final l10n = AppLocalizations.of(context)!;

    switch (state) {
      case SlotState.available:
        content = _buildAvailable(context, l10n);
        break;
      case SlotState.selected:
        content = _buildSelected(context, l10n);
        break;
      case SlotState.locked:
        content = _buildLocked(context, l10n);
        break;
      case SlotState.booked:
        content = _buildBooked(context, l10n);
        break;
    }

    Widget container = InkWell(
      onTap: (state == SlotState.available || state == SlotState.selected) ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
    
    if (state == SlotState.locked) {
      return container
        .animate(onPlay: (controller) => controller.repeat())
        .fade(duration: 1.seconds, begin: 0.5, end: 1.0)
        .then()
        .fade(duration: 1.seconds, begin: 1.0, end: 0.5);
    }
    
    return container;
  }

  Widget _buildAvailable(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.available,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelected(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: colorScheme.onPrimary, size: 14),
              const SizedBox(width: 4),
              Text(
                l10n.selected,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocked(BuildContext context, AppLocalizations l10n) {
    final warningColor = Colors.orange.shade100;
    final warningBorder = Colors.orange.shade700;
    final warningText = Colors.orange.shade900;
    
    return Container(
      decoration: BoxDecoration(
        color: warningColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warningBorder, width: 2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              color: warningText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: warningText, size: 14),
              const SizedBox(width: 4),
              Text(
                l10n.locked,
                style: TextStyle(
                  color: warningText,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBooked(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: colorScheme.onSurfaceVariant, size: 14),
              const SizedBox(width: 4),
              Text(
                l10n.booked,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
