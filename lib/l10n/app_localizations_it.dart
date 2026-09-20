// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Slotr';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get bookings => 'Prenotazioni';

  @override
  String get connected => 'Connesso';

  @override
  String get disconnected => 'Disconnesso';

  @override
  String get bookingConflictTitle => 'Conflitto di Prenotazione';

  @override
  String get bookingConflictDesc =>
      'Lo slot è stato bloccato da un altro utente.';

  @override
  String get errorTitle => 'Errore';

  @override
  String get errorDesc => 'Si è verificato un problema interno.';

  @override
  String get successTitle => 'Successo';

  @override
  String get successDesc => 'Prenotazione confermata con successo!';

  @override
  String get calendarAndSlots => 'CALENDARIO E SLOT ORARI';

  @override
  String get todayBookings => 'PRENOTAZIONI DELLA GIORNATA';

  @override
  String get noBookingsToday => 'Nessuna prenotazione per oggi.';

  @override
  String get cancel => 'Annulla';

  @override
  String get bookingForm => 'FORM DI PRENOTAZIONE';

  @override
  String get insertCheckoutData => 'Inserisci i dati per il checkout';

  @override
  String remainingTime(int seconds) {
    return 'Tempo residuo: ${seconds}s';
  }

  @override
  String get timerTooltipDesc =>
      'Questo timer serve ad evitare di bloccare lo slot indefinitamente per le altre persone. Si azzera se inizi a scrivere.';

  @override
  String get fullName => 'Nome Completo *';

  @override
  String get requiredField => 'Campo obbligatorio';

  @override
  String get selectedTimeSlot => 'Slot Orario Selezionato *';

  @override
  String get notes => 'Note';

  @override
  String get notesHint => 'Richiesta sessione di supporto...';

  @override
  String get confirm => 'Conferma';

  @override
  String get selectTimeSlotToContinue =>
      'Seleziona uno slot orario per continuare';

  @override
  String get available => 'DISPONIBILE';

  @override
  String get selected => 'SELEZIONATO';

  @override
  String get locked => 'BLOCCATO';

  @override
  String get booked => 'OCCUPATO';

  @override
  String get noConnectionToServer => 'Nessuna connessione al server.';

  @override
  String get retry => 'Riprova';

  @override
  String get networkErrorDesc =>
      'Errore di connessione. Verifica la connessione e riprova.';

  @override
  String get serverErrorDesc =>
      'Si è verificato un problema interno. Riprova più tardi.';

  @override
  String get cancelBookingConfirmText =>
      'Vuoi davvero annullare questa prenotazione?';
}
