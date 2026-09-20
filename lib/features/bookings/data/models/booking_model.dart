import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel extends Equatable {
  @JsonKey(includeIfNull: false)
  final String? id;
  final String name;
  final String date;
  @JsonKey(name: 'time_slot')
  final String timeSlot;
  final String? note;

  const BookingModel({
    this.id,
    required this.name,
    required this.date,
    required this.timeSlot,
    this.note,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  @override
  List<Object?> get props => [id, name, date, timeSlot, note];
}
