part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class FetchBookings extends BookingEvent {
  final String? date;
  
  const FetchBookings({this.date});
  
  @override
  List<Object?> get props => [date];
}

class SubmitBooking extends BookingEvent {
  final BookingModel booking;
  
  const SubmitBooking(this.booking);
  
  @override
  List<Object?> get props => [booking];
}

class DeleteBooking extends BookingEvent {
  final String id;
  
  const DeleteBooking(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LockSlot extends BookingEvent {
  final String date;
  final String timeSlot;
  
  const LockSlot({required this.date, required this.timeSlot});
  
  @override
  List<Object?> get props => [date, timeSlot];
}

class UnlockSlot extends BookingEvent {
  final String date;
  final String timeSlot;
  
  const UnlockSlot({required this.date, required this.timeSlot});
  
  @override
  List<Object?> get props => [date, timeSlot];
}

class WebSocketEventReceived extends BookingEvent {
  final Map<String, dynamic> data;
  
  const WebSocketEventReceived(this.data);
  
  @override
  List<Object?> get props => [data];
}
