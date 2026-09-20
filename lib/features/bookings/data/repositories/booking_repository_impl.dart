import 'package:dio/dio.dart';
import 'package:slotr_app/core/error/exceptions.dart';
import 'package:slotr_app/core/network/api_client.dart';
import 'package:slotr_app/features/bookings/data/models/booking_model.dart';
import 'package:slotr_app/features/bookings/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient apiClient;

  BookingRepositoryImpl({required this.apiClient});

  @override
  Future<List<BookingModel>> getBookings({String? date}) async {
    try {
      return await apiClient.getBookings(date);
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        throw NetworkException();
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      return await apiClient.createBooking(booking);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException();
      }
      if (_isNetworkError(e)) {
        throw NetworkException();
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteBooking(String id) async {
    try {
      await apiClient.deleteBooking(id);
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        throw NetworkException();
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
  }

  bool _isNetworkError(DioException e) {
    return e.response == null ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }
}
