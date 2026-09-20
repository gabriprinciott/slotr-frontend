import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slotr_app/core/error/exceptions.dart';
import 'package:slotr_app/core/logging/app_logger.dart';
import 'package:slotr_app/core/websocket/websocket_service.dart';
import 'package:slotr_app/features/bookings/data/models/booking_model.dart';
import 'package:slotr_app/features/bookings/domain/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;
  final WebSocketService wsService;
  StreamSubscription? _wsSubscription;

  BookingBloc({
    required this.repository,
    required this.wsService,
  }) : super(BookingState(selectedDate: DateTime.now())) {
    on<FetchBookings>(_onFetchBookings);
    on<SubmitBooking>(_onSubmitBooking);
    on<DeleteBooking>(_onDeleteBooking);
    on<LockSlot>(_onLockSlot);
    on<UnlockSlot>(_onUnlockSlot);
    on<WebSocketEventReceived>(_onWebSocketEventReceived);


    wsService.connect();
    _wsSubscription = wsService.stream?.listen(
      (data) {
        try {
          final parsed = jsonDecode(data);
          add(WebSocketEventReceived(parsed));
        } catch (_) {

        }
      },
      onError: (error) {
        log.w(
          '⚠️ Connessione in tempo reale non disponibile (${wsService.url}). Errore: $error\n'
          'Gli aggiornamenti istantanei sono temporaneamente disattivati.',
        );
      },
      onDone: () {
        log.d('Canale WebSocket chiuso.');
      },
      cancelOnError: false,
    );
  }

  Future<void> _onFetchBookings(FetchBookings event, Emitter<BookingState> emit) async {
    final targetDate = event.date != null ? DateTime.parse(event.date!) : state.selectedDate;
    final dateString = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    emit(state.copyWith(status: BookingStatus.loading, errorMessage: null, selectedDate: targetDate));
    try {
      final bookings = await repository.getBookings(date: dateString);
      emit(state.copyWith(
        status: BookingStatus.loaded,
        bookings: bookings,
      ));
    } on NetworkException catch (e) {
      log.w('⚠️ [CONNESSIONE NON DISPONIBILE] Caricamento prenotazioni fallito: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: e.message,
      ));
    } on ServerException catch (e) {
      log.w('⚠️ [ERRORE INTERNO] Caricamento fallito: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e, st) {
      log.e('Errore imprevisto durante il recupero delle prenotazioni', e, st);
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: ServerException().message,
      ));
    }
  }

  Future<void> _onSubmitBooking(SubmitBooking event, Emitter<BookingState> emit) async {
    emit(state.copyWith(status: BookingStatus.loading, errorMessage: null));
    try {
      final newBooking = await repository.createBooking(event.booking);
      
      final slotKey = '${event.booking.date}_${event.booking.timeSlot}';
      final newLocks = Set<String>.from(state.lockedSlots)..remove(slotKey);
      

      emit(state.copyWith(
        status: BookingStatus.success,
        bookings: List.of(state.bookings)..add(newBooking),
        lockedSlots: newLocks,
      ));
    } on NetworkException catch (e) {
      log.w('⚠️ [CONNESSIONE NON DISPONIBILE] Creazione prenotazione fallita: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: e.message,
      ));
    } on ConflictException catch (e) {
      log.w('⚠️ [CONFLITTO PRENOTAZIONE] Conflitto: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.conflict,
        errorMessage: e.message,
      ));
    } on ServerException catch (e) {
      log.w('⚠️ [ERRORE INTERNO] Creazione prenotazione fallita: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e, st) {
      log.e('Errore imprevisto durante la creazione della prenotazione', e, st);
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: ServerException().message,
      ));
    }
  }

  Future<void> _onDeleteBooking(DeleteBooking event, Emitter<BookingState> emit) async {
    try {
      await repository.deleteBooking(event.id);
      

      emit(state.copyWith(
        status: BookingStatus.loaded,
        bookings: state.bookings.where((b) => b.id != event.id).toList(),
      ));
    } on NetworkException catch (e) {
      log.w('⚠️ [CONNESSIONE NON DISPONIBILE] Cancellazione fallita: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: e.message,
      ));
    } on ServerException catch (e) {
      log.w('⚠️ [ERRORE INTERNO] Cancellazione fallita: ${e.message}');
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e, st) {
      log.e('Errore imprevisto durante la cancellazione della prenotazione', e, st);
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: ServerException().message,
      ));
    }
  }

  Future<void> _onLockSlot(LockSlot event, Emitter<BookingState> emit) async {

    wsService.send(jsonEncode({
      'type': 'LOCK_SLOT',
      'date': event.date,
      'timeSlot': event.timeSlot,
    }));
  }

  Future<void> _onUnlockSlot(UnlockSlot event, Emitter<BookingState> emit) async {

    wsService.send(jsonEncode({
      'type': 'UNLOCK_SLOT',
      'date': event.date,
      'timeSlot': event.timeSlot,
    }));
  }

  void _onWebSocketEventReceived(WebSocketEventReceived event, Emitter<BookingState> emit) {

    log.i(' [SOCKET EVENT INGRESSO] Payload Grezzo Ricevuto: ${event.data}');
    

    final rawType = event.data['type']?.toString() ?? '';
    final type = rawType.toUpperCase();
    
    final date = event.data['date'];
    final timeSlot = event.data['timeSlot'];
    

    final slotKey = '${date}_$timeSlot';

    if (type == 'SLOT_LOCKED') {
      final newLocks = Set<String>.from(state.lockedSlots)..add(slotKey);
      emit(state.copyWith(lockedSlots: newLocks));
    } else if (type == 'SLOT_UNLOCKED') {
      final newLocks = Set<String>.from(state.lockedSlots)..remove(slotKey);
      emit(state.copyWith(lockedSlots: newLocks));
    } else if (type == 'INITIAL_LOCKS') {

      final List<dynamic> locks = event.data['locks'] ?? [];
      final newLocks = Set<String>.from(state.lockedSlots);
      for (var lock in locks) {
        final lDate = lock['date'];
        final lTime = lock['timeSlot'];
        if (lDate != null && lTime != null) {
          newLocks.add('${lDate}_$lTime');
        }
      }
      emit(state.copyWith(lockedSlots: newLocks));
    } else if (type == 'SLOT_BOOKED' || type == 'NEW_BOOKING') {

      final newLocks = Set<String>.from(state.lockedSlots)..remove(slotKey);
      

      final currentBookings = List<BookingModel>.from(state.bookings);
      final selectedDateStr = "${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}";
      
      if (date != null && timeSlot != null && date == selectedDateStr) {
        if (!currentBookings.any((b) => b.timeSlot == timeSlot && b.date == date)) {
          currentBookings.add(BookingModel(
            id: 'temp_$slotKey',
            name: 'Occupato',
            date: date,
            timeSlot: timeSlot,
          ));
        }
      }
      
      emit(state.copyWith(
        lockedSlots: newLocks,
        bookings: currentBookings,
      ));
      

      add(const FetchBookings());
    } else if (type == 'BOOKING_DELETED') {

      add(const FetchBookings());
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    wsService.disconnect();
    return super.close();
  }
}
