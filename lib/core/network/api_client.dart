import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:slotr_app/features/bookings/data/models/booking_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/bookings')
  Future<List<BookingModel>> getBookings(@Query('date') String? date);

  @POST('/bookings')
  Future<BookingModel> createBooking(@Body() BookingModel booking);

  @DELETE('/bookings/{id}')
  Future<void> deleteBooking(@Path('id') String id);
}
