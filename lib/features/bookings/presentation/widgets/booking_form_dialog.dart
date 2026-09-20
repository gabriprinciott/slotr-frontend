import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slotr_app/features/bookings/data/models/booking_model.dart';
import 'package:slotr_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:slotr_app/l10n/app_localizations.dart';

class BookingFormInlineWidget extends StatefulWidget {
  final String timeSlot;
  final VoidCallback onCancel;

  const BookingFormInlineWidget({
    super.key,
    required this.timeSlot,
    required this.onCancel,
  });

  @override
  State<BookingFormInlineWidget> createState() => _BookingFormInlineWidgetState();
}

class _BookingFormInlineWidgetState extends State<BookingFormInlineWidget> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _remainingSeconds = 120;
  Timer? _countdownTimer;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant BookingFormInlineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeSlot != widget.timeSlot) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 120;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        widget.onCancel();
      }
    });
  }

  void _onUserInteraction(String _) {
    setState(() {
      _remainingSeconds = 120;
    });
    _countdownTimer?.cancel();
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 1), () {
      _startCountdown();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _typingTimer?.cancel();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _remainingSeconds > 0) {
      final state = context.read<BookingBloc>().state;
      final dateStr = "${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}";
      
      final booking = BookingModel(
        name: _nameController.text,
        date: dateStr,
        timeSlot: widget.timeSlot,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      
      context.read<BookingBloc>().add(SubmitBooking(booking));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = _remainingSeconds <= 0;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.insertCheckoutData,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExpired ? colorScheme.errorContainer : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isExpired ? colorScheme.error : colorScheme.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpired ? Icons.timer_off : Icons.timer,
                      size: 14,
                      color: isExpired ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.remainingTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: l10n.timerTooltipDesc,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 4),
                      child: Icon(
                        Icons.help_outline,
                        size: 14,
                        color: isExpired ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            enabled: !isExpired,
            onChanged: _onUserInteraction,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.timeSlot,
            enabled: false,
            decoration: InputDecoration(
              labelText: l10n.selectedTimeSlot,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.access_time),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            enabled: !isExpired,
            onChanged: _onUserInteraction,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.notes,
              hintText: l10n.notesHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.cancel, style: TextStyle(color: colorScheme.onSurface)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isExpired ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
