import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slotr_app/core/di/injection.dart';
import 'package:slotr_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:slotr_app/features/bookings/presentation/widgets/time_slots_grid_widget.dart';
import 'package:slotr_app/features/bookings/presentation/widgets/booking_form_dialog.dart';
import 'package:slotr_app/core/websocket/websocket_service.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:slotr_app/core/bloc/app_settings_cubit.dart';
import 'package:slotr_app/l10n/app_localizations.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookingBloc>()..add(const FetchBookings()),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  String? _selectedTimeSlot;
  late final WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _wsService = getIt<WebSocketService>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String currentLocale = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/icon.png', height: 32, width: 32),
            const SizedBox(width: 8),
            Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (MediaQuery.of(context).size.width >= 600) ...[
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: Text(l10n.bookings, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              context.read<AppSettingsCubit>().toggleTheme(context);
            },
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              context.read<AppSettingsCubit>().setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return AppLocalizations.supportedLocales.map((Locale locale) {
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.languageCode == 'it' ? ' Italiano' : ' English'),
                );
              }).toList();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ValueListenableBuilder<ConnectionStatus>(
              valueListenable: _wsService.status,
              builder: (context, status, child) {
                final isConnected = status == ConnectionStatus.connected;
                final color = isConnected ? colorScheme.primary : colorScheme.error;
                final bgColor = isConnected ? colorScheme.primaryContainer : colorScheme.errorContainer;
                final labelText = isConnected ? l10n.connected : l10n.disconnected;

                if (MediaQuery.of(context).size.width < 600) {
                  return Tooltip(
                    message: labelText,
                    child: CircleAvatar(
                      backgroundColor: bgColor,
                      radius: 12,
                      child: Icon(Icons.circle, color: color, size: 12),
                    ),
                  );
                }

                return Chip(
                  backgroundColor: bgColor,
                  side: BorderSide(color: color),
                  avatar: Icon(Icons.circle, color: color, size: 12),
                  label: Text(
                    labelText,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<ConnectionStatus>(
        valueListenable: _wsService.status,
        builder: (context, status, child) {
          return Stack(
            children: [

              BlocListener<BookingBloc, BookingState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status || previous.errorMessage != current.errorMessage,
                listener: (context, state) {
                  if (state.status == BookingStatus.conflict) {
                    final desc = state.errorMessage == 'conflict_error'
                        ? l10n.bookingConflictDesc
                        : state.errorMessage ?? l10n.bookingConflictDesc;
                    toastification.show(
                      context: context,
                      title: Text(l10n.bookingConflictTitle),
                      description: Text(desc),
                      type: ToastificationType.warning,
                      style: ToastificationStyle.flatColored,
                      autoCloseDuration: const Duration(seconds: 4),
                      icon: const Icon(Icons.warning_rounded),
                      alignment: Alignment.bottomCenter,
                    );
                  } else if (state.status == BookingStatus.failure) {
                    String desc = l10n.errorDesc;
                    if (state.errorMessage == 'network_error') {
                      desc = l10n.networkErrorDesc;
                    } else if (state.errorMessage == 'server_error') {
                      desc = l10n.serverErrorDesc;
                    } else if (state.errorMessage != null) {
                      desc = state.errorMessage!;
                    }
                    toastification.show(
                      context: context,
                      title: Text(l10n.errorTitle),
                      description: Text(desc),
                      type: ToastificationType.error,
                      style: ToastificationStyle.flatColored,
                      autoCloseDuration: const Duration(seconds: 4),
                      alignment: Alignment.bottomCenter,
                    );
                  } else if (state.status == BookingStatus.success) {
                    toastification.show(
                      context: context,
                      title: Text(l10n.successTitle),
                      description: Text(l10n.successDesc),
                      type: ToastificationType.success,
                      style: ToastificationStyle.flatColored,
                      autoCloseDuration: const Duration(seconds: 3),
                      alignment: Alignment.bottomCenter,
                    );
                    setState(() {
                      _selectedTimeSlot = null;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 800;

                      final calendarAndSlots = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.calendarAndSlots,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                BlocBuilder<BookingBloc, BookingState>(
                                  buildWhen: (previous, current) => previous.selectedDate != current.selectedDate,
                                  builder: (context, state) {
                                    return EasyDateTimeLine(
                                      key: ValueKey(state.selectedDate),
                                      initialDate: state.selectedDate,
                                      locale: currentLocale,
                                      onDateChange: (selectedDate) {
                                        context.read<BookingBloc>().add(FetchBookings(date: selectedDate.toIso8601String()));
                                      },
                                      headerProps: EasyHeaderProps(
                                        monthPickerType: MonthPickerType.switcher,
                                        dateFormatter: const DateFormatter.fullDateDMY(),
                                        monthStyle: TextStyle(color: colorScheme.onSurface),
                                        selectedDateStyle: TextStyle(color: colorScheme.onSurface),
                                      ),
                                      dayProps: EasyDayProps(
                                        dayStructure: DayStructure.dayStrDayNum,
                                        activeDayStyle: DayStyle(
                                          dayNumStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                          dayStrStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 12),
                                          monthStrStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        inactiveDayStyle: DayStyle(
                                          dayNumStyle: TextStyle(color: colorScheme.onSurface, fontSize: 18),
                                          dayStrStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                                          monthStrStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            color: colorScheme.surfaceContainerHighest,
                                          ),
                                        ),
                                        todayStyle: DayStyle(
                                          dayNumStyle: TextStyle(color: colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                                          dayStrStyle: TextStyle(color: colorScheme.primary, fontSize: 12),
                                          monthStrStyle: TextStyle(color: colorScheme.primary, fontSize: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            border: Border.all(color: colorScheme.primary),
                                            color: colorScheme.surface,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                                SizedBox(
                                  height: 400,
                                  child: TimeSlotsGridWidget(
                                    selectedTimeSlot: _selectedTimeSlot,
                                    onSlotSelected: (slot) {
                                      setState(() {
                                        _selectedTimeSlot = slot.isEmpty ? null : slot;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          BlocBuilder<BookingBloc, BookingState>(
                            builder: (context, state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.todayBookings,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: colorScheme.outlineVariant),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: state.bookings.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Center(child: Text(l10n.noBookingsToday)),
                                          )
                                        : ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: state.bookings.length,
                                            separatorBuilder: (_, __) => const Divider(height: 1),
                                            itemBuilder: (context, index) {
                                              final booking = state.bookings[index];
                                              return ListTile(
                                                leading: Icon(Icons.schedule, color: colorScheme.primary),
                                                title: Text("${booking.timeSlot} | ${booking.name}"),
                                                subtitle: Text("${l10n.notes}: ${booking.note ?? '-'}"),
                                                trailing: TextButton.icon(
                                                  onPressed: () {
                                                    if (booking.id != null) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: Text(l10n.cancel),
                                                          content: Text(l10n.cancelBookingConfirmText),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(ctx),
                                                              child: Text(l10n.cancel),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(ctx);
                                                                context.read<BookingBloc>().add(DeleteBooking(booking.id!));
                                                              },
                                                              child: Text(l10n.confirm),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                                                  label: Text(l10n.cancel, style: TextStyle(color: colorScheme.error)),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              );
                            }
                          ),
                        ],
                      );

                      final bookingForm = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bookingForm,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: Border.all(color: colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: _selectedTimeSlot == null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        l10n.selectTimeSlotToContinue,
                                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                  )
                                : BookingFormInlineWidget(
                                    timeSlot: _selectedTimeSlot!,
                                    onCancel: () {
                                      setState(() {
                                        _selectedTimeSlot = null;
                                      });
                                    },
                                  ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0),
                          ),
                        ],
                      );

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: calendarAndSlots),
                            const SizedBox(width: 32),
                            Expanded(flex: 2, child: bookingForm),
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              calendarAndSlots,
                              const SizedBox(height: 32),
                              bookingForm,
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              if (status == ConnectionStatus.disconnected)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 64, color: colorScheme.error),
                            const SizedBox(height: 16),
                            Text(
                              l10n.disconnected,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noConnectionToServer,
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () {
                                _wsService.connect();
                                context.read<BookingBloc>().add(const FetchBookings());
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
