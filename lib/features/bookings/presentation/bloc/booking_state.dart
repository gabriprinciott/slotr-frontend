part of 'booking_bloc.dart';

enum BookingStatus { initial, loading, loaded, success, failure, conflict }

class BookingState extends Equatable {
  final BookingStatus status;
  final List<BookingModel> bookings;
  final Set<String> lockedSlots;
  final String? errorMessage;
  final DateTime selectedDate;

  const BookingState({
    this.status = BookingStatus.initial,
    this.bookings = const [],
    this.lockedSlots = const {},
    this.errorMessage,
    required this.selectedDate,
  });

  BookingState copyWith({
    BookingStatus? status,
    List<BookingModel>? bookings,
    Set<String>? lockedSlots,
    String? errorMessage,
    DateTime? selectedDate,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      lockedSlots: lockedSlots ?? this.lockedSlots,
      errorMessage: errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [status, bookings, lockedSlots, errorMessage, selectedDate];
}
