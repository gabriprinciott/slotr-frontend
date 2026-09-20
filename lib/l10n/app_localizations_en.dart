// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Slotr';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get bookings => 'Bookings';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get bookingConflictTitle => 'Booking Conflict';

  @override
  String get bookingConflictDesc => 'The slot was locked by another user.';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorDesc => 'An internal error occurred.';

  @override
  String get successTitle => 'Success';

  @override
  String get successDesc => 'Booking confirmed successfully!';

  @override
  String get calendarAndSlots => 'CALENDAR & TIME SLOTS';

  @override
  String get todayBookings => 'TODAY\'S BOOKINGS';

  @override
  String get noBookingsToday => 'No bookings for today.';

  @override
  String get cancel => 'Cancel';

  @override
  String get bookingForm => 'BOOKING FORM';

  @override
  String get insertCheckoutData => 'Enter checkout details';

  @override
  String remainingTime(int seconds) {
    return 'Time left: ${seconds}s';
  }

  @override
  String get timerTooltipDesc =>
      'This timer prevents the slot from being locked indefinitely for other users. It resets when you type.';

  @override
  String get fullName => 'Full Name *';

  @override
  String get requiredField => 'Required field';

  @override
  String get selectedTimeSlot => 'Selected Time Slot *';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Support session request...';

  @override
  String get confirm => 'Confirm';

  @override
  String get selectTimeSlotToContinue => 'Select a time slot to continue';

  @override
  String get available => 'AVAILABLE';

  @override
  String get selected => 'SELECTED';

  @override
  String get locked => 'LOCKED';

  @override
  String get booked => 'BOOKED';

  @override
  String get noConnectionToServer => 'No connection to the server.';

  @override
  String get retry => 'Retry';

  @override
  String get networkErrorDesc =>
      'Connection error. Check your connection and try again.';

  @override
  String get serverErrorDesc =>
      'An internal problem occurred. Please try again later.';

  @override
  String get cancelBookingConfirmText =>
      'Do you really want to cancel this booking?';
}
