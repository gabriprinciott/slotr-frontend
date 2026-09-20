

part of 'booking_model.dart';





BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String?,
  name: json['name'] as String,
  date: json['date'] as String,
  timeSlot: json['time_slot'] as String,
  note: json['note'] as String?,
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'date': instance.date,
      'time_slot': instance.timeSlot,
      'note': instance.note,
    };
