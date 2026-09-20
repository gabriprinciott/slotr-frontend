import 'package:slotr_app/features/bookings/data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookings({String? date});
  Future<BookingModel> createBooking(BookingModel booking);
  Future<void> deleteBooking(String id);
}
