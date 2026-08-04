import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

@freezed
class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    required String id,
    required int month,
    required int year,
    required bool isOpen,
    @Default([]) List<ScheduleDateModel> dates,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);
}

@freezed
class ScheduleDateModel with _$ScheduleDateModel {
  const factory ScheduleDateModel({
    required String id,
    required DateTime date,
    required String scheduleId,
    @Default([]) List<AvailabilityModel> availabilities,
  }) = _ScheduleDateModel;

  factory ScheduleDateModel.fromJson(Map<String, dynamic> json) => _$ScheduleDateModelFromJson(json);
}

@freezed
class AvailabilityModel with _$AvailabilityModel {
  const factory AvailabilityModel({
    required String id,
    required String userId,
    required String scheduleDateId,
    required String status,
    UserModel? user,
  }) = _AvailabilityModel;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) => _$AvailabilityModelFromJson(json);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
