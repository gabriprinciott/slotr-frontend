import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Slotr'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @bookingConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Conflict'**
  String get bookingConflictTitle;

  /// No description provided for @bookingConflictDesc.
  ///
  /// In en, this message translates to:
  /// **'The slot was locked by another user.'**
  String get bookingConflictDesc;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorDesc.
  ///
  /// In en, this message translates to:
  /// **'An internal error occurred.'**
  String get errorDesc;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @successDesc.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed successfully!'**
  String get successDesc;

  /// No description provided for @calendarAndSlots.
  ///
  /// In en, this message translates to:
  /// **'CALENDAR & TIME SLOTS'**
  String get calendarAndSlots;

  /// No description provided for @todayBookings.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S BOOKINGS'**
  String get todayBookings;

  /// No description provided for @noBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'No bookings for today.'**
  String get noBookingsToday;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @bookingForm.
  ///
  /// In en, this message translates to:
  /// **'BOOKING FORM'**
  String get bookingForm;

  /// No description provided for @insertCheckoutData.
  ///
  /// In en, this message translates to:
  /// **'Enter checkout details'**
  String get insertCheckoutData;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Time left: {seconds}s'**
  String remainingTime(int seconds);

  /// No description provided for @timerTooltipDesc.
  ///
  /// In en, this message translates to:
  /// **'This timer prevents the slot from being locked indefinitely for other users. It resets when you type.'**
  String get timerTooltipDesc;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullName;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @selectedTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Selected Time Slot *'**
  String get selectedTimeSlot;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Support session request...'**
  String get notesHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @selectTimeSlotToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select a time slot to continue'**
  String get selectTimeSlotToContinue;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get available;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get selected;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get locked;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'BOOKED'**
  String get booked;

  /// No description provided for @noConnectionToServer.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server.'**
  String get noConnectionToServer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @networkErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your connection and try again.'**
  String get networkErrorDesc;

  /// No description provided for @serverErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'An internal problem occurred. Please try again later.'**
  String get serverErrorDesc;

  /// No description provided for @cancelBookingConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to cancel this booking?'**
  String get cancelBookingConfirmText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
