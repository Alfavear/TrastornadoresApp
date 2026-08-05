// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) {
  return _ScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleModel {
  String get id => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  bool get isOpen => throw _privateConstructorUsedError;
  List<ScheduleDateModel> get dates => throw _privateConstructorUsedError;

  /// Serializes this ScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleModelCopyWith<ScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleModelCopyWith<$Res> {
  factory $ScheduleModelCopyWith(
          ScheduleModel value, $Res Function(ScheduleModel) then) =
      _$ScheduleModelCopyWithImpl<$Res, ScheduleModel>;
  @useResult
  $Res call(
      {String id,
      int month,
      int year,
      bool isOpen,
      List<ScheduleDateModel> dates});
}

/// @nodoc
class _$ScheduleModelCopyWithImpl<$Res, $Val extends ScheduleModel>
    implements $ScheduleModelCopyWith<$Res> {
  _$ScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? year = null,
    Object? isOpen = null,
    Object? dates = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      dates: null == dates
          ? _value.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<ScheduleDateModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleModelImplCopyWith<$Res>
    implements $ScheduleModelCopyWith<$Res> {
  factory _$$ScheduleModelImplCopyWith(
          _$ScheduleModelImpl value, $Res Function(_$ScheduleModelImpl) then) =
      __$$ScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int month,
      int year,
      bool isOpen,
      List<ScheduleDateModel> dates});
}

/// @nodoc
class __$$ScheduleModelImplCopyWithImpl<$Res>
    extends _$ScheduleModelCopyWithImpl<$Res, _$ScheduleModelImpl>
    implements _$$ScheduleModelImplCopyWith<$Res> {
  __$$ScheduleModelImplCopyWithImpl(
      _$ScheduleModelImpl _value, $Res Function(_$ScheduleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? year = null,
    Object? isOpen = null,
    Object? dates = null,
  }) {
    return _then(_$ScheduleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      dates: null == dates
          ? _value._dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<ScheduleDateModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleModelImpl implements _ScheduleModel {
  const _$ScheduleModelImpl(
      {required this.id,
      required this.month,
      required this.year,
      required this.isOpen,
      final List<ScheduleDateModel> dates = const []})
      : _dates = dates;

  factory _$ScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleModelImplFromJson(json);

  @override
  final String id;
  @override
  final int month;
  @override
  final int year;
  @override
  final bool isOpen;
  final List<ScheduleDateModel> _dates;
  @override
  @JsonKey()
  List<ScheduleDateModel> get dates {
    if (_dates is EqualUnmodifiableListView) return _dates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dates);
  }

  @override
  String toString() {
    return 'ScheduleModel(id: $id, month: $month, year: $year, isOpen: $isOpen, dates: $dates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            const DeepCollectionEquality().equals(other._dates, _dates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, month, year, isOpen,
      const DeepCollectionEquality().hash(_dates));

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      __$$ScheduleModelImplCopyWithImpl<_$ScheduleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleModel implements ScheduleModel {
  const factory _ScheduleModel(
      {required final String id,
      required final int month,
      required final int year,
      required final bool isOpen,
      final List<ScheduleDateModel> dates}) = _$ScheduleModelImpl;

  factory _ScheduleModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleModelImpl.fromJson;

  @override
  String get id;
  @override
  int get month;
  @override
  int get year;
  @override
  bool get isOpen;
  @override
  List<ScheduleDateModel> get dates;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleDateModel _$ScheduleDateModelFromJson(Map<String, dynamic> json) {
  return _ScheduleDateModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleDateModel {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get scheduleId => throw _privateConstructorUsedError;
  List<AvailabilityModel> get availabilities =>
      throw _privateConstructorUsedError;

  /// Serializes this ScheduleDateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleDateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleDateModelCopyWith<ScheduleDateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleDateModelCopyWith<$Res> {
  factory $ScheduleDateModelCopyWith(
          ScheduleDateModel value, $Res Function(ScheduleDateModel) then) =
      _$ScheduleDateModelCopyWithImpl<$Res, ScheduleDateModel>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String scheduleId,
      List<AvailabilityModel> availabilities});
}

/// @nodoc
class _$ScheduleDateModelCopyWithImpl<$Res, $Val extends ScheduleDateModel>
    implements $ScheduleDateModelCopyWith<$Res> {
  _$ScheduleDateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleDateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? scheduleId = null,
    Object? availabilities = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      availabilities: null == availabilities
          ? _value.availabilities
          : availabilities // ignore: cast_nullable_to_non_nullable
              as List<AvailabilityModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleDateModelImplCopyWith<$Res>
    implements $ScheduleDateModelCopyWith<$Res> {
  factory _$$ScheduleDateModelImplCopyWith(_$ScheduleDateModelImpl value,
          $Res Function(_$ScheduleDateModelImpl) then) =
      __$$ScheduleDateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String scheduleId,
      List<AvailabilityModel> availabilities});
}

/// @nodoc
class __$$ScheduleDateModelImplCopyWithImpl<$Res>
    extends _$ScheduleDateModelCopyWithImpl<$Res, _$ScheduleDateModelImpl>
    implements _$$ScheduleDateModelImplCopyWith<$Res> {
  __$$ScheduleDateModelImplCopyWithImpl(_$ScheduleDateModelImpl _value,
      $Res Function(_$ScheduleDateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleDateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? scheduleId = null,
    Object? availabilities = null,
  }) {
    return _then(_$ScheduleDateModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      availabilities: null == availabilities
          ? _value._availabilities
          : availabilities // ignore: cast_nullable_to_non_nullable
              as List<AvailabilityModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleDateModelImpl implements _ScheduleDateModel {
  const _$ScheduleDateModelImpl(
      {required this.id,
      required this.date,
      required this.scheduleId,
      final List<AvailabilityModel> availabilities = const []})
      : _availabilities = availabilities;

  factory _$ScheduleDateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleDateModelImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String scheduleId;
  final List<AvailabilityModel> _availabilities;
  @override
  @JsonKey()
  List<AvailabilityModel> get availabilities {
    if (_availabilities is EqualUnmodifiableListView) return _availabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availabilities);
  }

  @override
  String toString() {
    return 'ScheduleDateModel(id: $id, date: $date, scheduleId: $scheduleId, availabilities: $availabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleDateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            const DeepCollectionEquality()
                .equals(other._availabilities, _availabilities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, date, scheduleId,
      const DeepCollectionEquality().hash(_availabilities));

  /// Create a copy of ScheduleDateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleDateModelImplCopyWith<_$ScheduleDateModelImpl> get copyWith =>
      __$$ScheduleDateModelImplCopyWithImpl<_$ScheduleDateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleDateModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleDateModel implements ScheduleDateModel {
  const factory _ScheduleDateModel(
      {required final String id,
      required final DateTime date,
      required final String scheduleId,
      final List<AvailabilityModel> availabilities}) = _$ScheduleDateModelImpl;

  factory _ScheduleDateModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleDateModelImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get scheduleId;
  @override
  List<AvailabilityModel> get availabilities;

  /// Create a copy of ScheduleDateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleDateModelImplCopyWith<_$ScheduleDateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailabilityModel _$AvailabilityModelFromJson(Map<String, dynamic> json) {
  return _AvailabilityModel.fromJson(json);
}

/// @nodoc
mixin _$AvailabilityModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get scheduleDateId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  UserModel? get user => throw _privateConstructorUsedError;

  /// Serializes this AvailabilityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilityModelCopyWith<AvailabilityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailabilityModelCopyWith<$Res> {
  factory $AvailabilityModelCopyWith(
          AvailabilityModel value, $Res Function(AvailabilityModel) then) =
      _$AvailabilityModelCopyWithImpl<$Res, AvailabilityModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String scheduleDateId,
      String status,
      UserModel? user});

  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class _$AvailabilityModelCopyWithImpl<$Res, $Val extends AvailabilityModel>
    implements $AvailabilityModelCopyWith<$Res> {
  _$AvailabilityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scheduleDateId = null,
    Object? status = null,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduleDateId: null == scheduleDateId
          ? _value.scheduleDateId
          : scheduleDateId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  /// Create a copy of AvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AvailabilityModelImplCopyWith<$Res>
    implements $AvailabilityModelCopyWith<$Res> {
  factory _$$AvailabilityModelImplCopyWith(_$AvailabilityModelImpl value,
          $Res Function(_$AvailabilityModelImpl) then) =
      __$$AvailabilityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String scheduleDateId,
      String status,
      UserModel? user});

  @override
  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AvailabilityModelImplCopyWithImpl<$Res>
    extends _$AvailabilityModelCopyWithImpl<$Res, _$AvailabilityModelImpl>
    implements _$$AvailabilityModelImplCopyWith<$Res> {
  __$$AvailabilityModelImplCopyWithImpl(_$AvailabilityModelImpl _value,
      $Res Function(_$AvailabilityModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scheduleDateId = null,
    Object? status = null,
    Object? user = freezed,
  }) {
    return _then(_$AvailabilityModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduleDateId: null == scheduleDateId
          ? _value.scheduleDateId
          : scheduleDateId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailabilityModelImpl implements _AvailabilityModel {
  const _$AvailabilityModelImpl(
      {required this.id,
      required this.userId,
      required this.scheduleDateId,
      required this.status,
      this.user});

  factory _$AvailabilityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailabilityModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String scheduleDateId;
  @override
  final String status;
  @override
  final UserModel? user;

  @override
  String toString() {
    return 'AvailabilityModel(id: $id, userId: $userId, scheduleDateId: $scheduleDateId, status: $status, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.scheduleDateId, scheduleDateId) ||
                other.scheduleDateId == scheduleDateId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, scheduleDateId, status, user);

  /// Create a copy of AvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilityModelImplCopyWith<_$AvailabilityModelImpl> get copyWith =>
      __$$AvailabilityModelImplCopyWithImpl<_$AvailabilityModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailabilityModelImplToJson(
      this,
    );
  }
}

abstract class _AvailabilityModel implements AvailabilityModel {
  const factory _AvailabilityModel(
      {required final String id,
      required final String userId,
      required final String scheduleDateId,
      required final String status,
      final UserModel? user}) = _$AvailabilityModelImpl;

  factory _AvailabilityModel.fromJson(Map<String, dynamic> json) =
      _$AvailabilityModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get scheduleDateId;
  @override
  String get status;
  @override
  UserModel? get user;

  /// Create a copy of AvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilityModelImplCopyWith<_$AvailabilityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({String id, String name, String email});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String email});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.id, required this.name, required this.email});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final String id,
      required final String name,
      required final String email}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
