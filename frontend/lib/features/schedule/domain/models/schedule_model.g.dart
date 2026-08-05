// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleModelImpl _$$ScheduleModelImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleModelImpl(
      id: json['id'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      isOpen: json['isOpen'] as bool,
      dates: (json['dates'] as List<dynamic>?)
              ?.map(
                  (e) => ScheduleDateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ScheduleModelImplToJson(_$ScheduleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'month': instance.month,
      'year': instance.year,
      'isOpen': instance.isOpen,
      'dates': instance.dates,
    };

_$ScheduleDateModelImpl _$$ScheduleDateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScheduleDateModelImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      scheduleId: json['scheduleId'] as String,
      availabilities: (json['availabilities'] as List<dynamic>?)
              ?.map(
                  (e) => AvailabilityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ScheduleDateModelImplToJson(
        _$ScheduleDateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'scheduleId': instance.scheduleId,
      'availabilities': instance.availabilities,
    };

_$AvailabilityModelImpl _$$AvailabilityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AvailabilityModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      scheduleDateId: json['scheduleDateId'] as String,
      status: json['status'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AvailabilityModelImplToJson(
        _$AvailabilityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'scheduleDateId': instance.scheduleDateId,
      'status': instance.status,
      'user': instance.user,
    };

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
