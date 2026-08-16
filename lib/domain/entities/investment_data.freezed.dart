// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investment_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InvestmentResult _$InvestmentResultFromJson(Map<String, dynamic> json) {
  return _InvestmentResult.fromJson(json);
}

/// @nodoc
mixin _$InvestmentResult {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  InvestmentType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  int get months => throw _privateConstructorUsedError;
  double get totalBruto => throw _privateConstructorUsedError;
  double get totalNeto => throw _privateConstructorUsedError;
  double get profitBruto => throw _privateConstructorUsedError;
  double get profitNeto => throw _privateConstructorUsedError;
  double get retencionAplicada => throw _privateConstructorUsedError;
  CalculationMethod get method => throw _privateConstructorUsedError;
  double get porcentajeRetencion => throw _privateConstructorUsedError;
  List<double>? get monthlyRates => throw _privateConstructorUsedError;
  List<double>? get progressionPoints => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get monthlyBreakdown =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvestmentResultCopyWith<InvestmentResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestmentResultCopyWith<$Res> {
  factory $InvestmentResultCopyWith(
          InvestmentResult value, $Res Function(InvestmentResult) then) =
      _$InvestmentResultCopyWithImpl<$Res, InvestmentResult>;
  @useResult
  $Res call(
      {String id,
      String label,
      InvestmentType type,
      double amount,
      double rate,
      int months,
      double totalBruto,
      double totalNeto,
      double profitBruto,
      double profitNeto,
      double retencionAplicada,
      CalculationMethod method,
      double porcentajeRetencion,
      List<double>? monthlyRates,
      List<double>? progressionPoints,
      List<Map<String, dynamic>> monthlyBreakdown});
}

/// @nodoc
class _$InvestmentResultCopyWithImpl<$Res, $Val extends InvestmentResult>
    implements $InvestmentResultCopyWith<$Res> {
  _$InvestmentResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? amount = null,
    Object? rate = null,
    Object? months = null,
    Object? totalBruto = null,
    Object? totalNeto = null,
    Object? profitBruto = null,
    Object? profitNeto = null,
    Object? retencionAplicada = null,
    Object? method = null,
    Object? porcentajeRetencion = null,
    Object? monthlyRates = freezed,
    Object? progressionPoints = freezed,
    Object? monthlyBreakdown = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InvestmentType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      months: null == months
          ? _value.months
          : months // ignore: cast_nullable_to_non_nullable
              as int,
      totalBruto: null == totalBruto
          ? _value.totalBruto
          : totalBruto // ignore: cast_nullable_to_non_nullable
              as double,
      totalNeto: null == totalNeto
          ? _value.totalNeto
          : totalNeto // ignore: cast_nullable_to_non_nullable
              as double,
      profitBruto: null == profitBruto
          ? _value.profitBruto
          : profitBruto // ignore: cast_nullable_to_non_nullable
              as double,
      profitNeto: null == profitNeto
          ? _value.profitNeto
          : profitNeto // ignore: cast_nullable_to_non_nullable
              as double,
      retencionAplicada: null == retencionAplicada
          ? _value.retencionAplicada
          : retencionAplicada // ignore: cast_nullable_to_non_nullable
              as double,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as CalculationMethod,
      porcentajeRetencion: null == porcentajeRetencion
          ? _value.porcentajeRetencion
          : porcentajeRetencion // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyRates: freezed == monthlyRates
          ? _value.monthlyRates
          : monthlyRates // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      progressionPoints: freezed == progressionPoints
          ? _value.progressionPoints
          : progressionPoints // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      monthlyBreakdown: null == monthlyBreakdown
          ? _value.monthlyBreakdown
          : monthlyBreakdown // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvestmentResultImplCopyWith<$Res>
    implements $InvestmentResultCopyWith<$Res> {
  factory _$$InvestmentResultImplCopyWith(_$InvestmentResultImpl value,
          $Res Function(_$InvestmentResultImpl) then) =
      __$$InvestmentResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      InvestmentType type,
      double amount,
      double rate,
      int months,
      double totalBruto,
      double totalNeto,
      double profitBruto,
      double profitNeto,
      double retencionAplicada,
      CalculationMethod method,
      double porcentajeRetencion,
      List<double>? monthlyRates,
      List<double>? progressionPoints,
      List<Map<String, dynamic>> monthlyBreakdown});
}

/// @nodoc
class __$$InvestmentResultImplCopyWithImpl<$Res>
    extends _$InvestmentResultCopyWithImpl<$Res, _$InvestmentResultImpl>
    implements _$$InvestmentResultImplCopyWith<$Res> {
  __$$InvestmentResultImplCopyWithImpl(_$InvestmentResultImpl _value,
      $Res Function(_$InvestmentResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? amount = null,
    Object? rate = null,
    Object? months = null,
    Object? totalBruto = null,
    Object? totalNeto = null,
    Object? profitBruto = null,
    Object? profitNeto = null,
    Object? retencionAplicada = null,
    Object? method = null,
    Object? porcentajeRetencion = null,
    Object? monthlyRates = freezed,
    Object? progressionPoints = freezed,
    Object? monthlyBreakdown = null,
  }) {
    return _then(_$InvestmentResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InvestmentType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      months: null == months
          ? _value.months
          : months // ignore: cast_nullable_to_non_nullable
              as int,
      totalBruto: null == totalBruto
          ? _value.totalBruto
          : totalBruto // ignore: cast_nullable_to_non_nullable
              as double,
      totalNeto: null == totalNeto
          ? _value.totalNeto
          : totalNeto // ignore: cast_nullable_to_non_nullable
              as double,
      profitBruto: null == profitBruto
          ? _value.profitBruto
          : profitBruto // ignore: cast_nullable_to_non_nullable
              as double,
      profitNeto: null == profitNeto
          ? _value.profitNeto
          : profitNeto // ignore: cast_nullable_to_non_nullable
              as double,
      retencionAplicada: null == retencionAplicada
          ? _value.retencionAplicada
          : retencionAplicada // ignore: cast_nullable_to_non_nullable
              as double,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as CalculationMethod,
      porcentajeRetencion: null == porcentajeRetencion
          ? _value.porcentajeRetencion
          : porcentajeRetencion // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyRates: freezed == monthlyRates
          ? _value._monthlyRates
          : monthlyRates // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      progressionPoints: freezed == progressionPoints
          ? _value._progressionPoints
          : progressionPoints // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      monthlyBreakdown: null == monthlyBreakdown
          ? _value._monthlyBreakdown
          : monthlyBreakdown // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvestmentResultImpl implements _InvestmentResult {
  const _$InvestmentResultImpl(
      {required this.id,
      required this.label,
      required this.type,
      required this.amount,
      required this.rate,
      required this.months,
      required this.totalBruto,
      required this.totalNeto,
      required this.profitBruto,
      required this.profitNeto,
      this.retencionAplicada = 0.0,
      required this.method,
      this.porcentajeRetencion = 0.0,
      required final List<double>? monthlyRates,
      required final List<double>? progressionPoints,
      required final List<Map<String, dynamic>> monthlyBreakdown})
      : _monthlyRates = monthlyRates,
        _progressionPoints = progressionPoints,
        _monthlyBreakdown = monthlyBreakdown;

  factory _$InvestmentResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestmentResultImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final InvestmentType type;
  @override
  final double amount;
  @override
  final double rate;
  @override
  final int months;
  @override
  final double totalBruto;
  @override
  final double totalNeto;
  @override
  final double profitBruto;
  @override
  final double profitNeto;
  @override
  @JsonKey()
  final double retencionAplicada;
  @override
  final CalculationMethod method;
  @override
  @JsonKey()
  final double porcentajeRetencion;
  final List<double>? _monthlyRates;
  @override
  List<double>? get monthlyRates {
    final value = _monthlyRates;
    if (value == null) return null;
    if (_monthlyRates is EqualUnmodifiableListView) return _monthlyRates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<double>? _progressionPoints;
  @override
  List<double>? get progressionPoints {
    final value = _progressionPoints;
    if (value == null) return null;
    if (_progressionPoints is EqualUnmodifiableListView)
      return _progressionPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Map<String, dynamic>> _monthlyBreakdown;
  @override
  List<Map<String, dynamic>> get monthlyBreakdown {
    if (_monthlyBreakdown is EqualUnmodifiableListView)
      return _monthlyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyBreakdown);
  }

  @override
  String toString() {
    return 'InvestmentResult(id: $id, label: $label, type: $type, amount: $amount, rate: $rate, months: $months, totalBruto: $totalBruto, totalNeto: $totalNeto, profitBruto: $profitBruto, profitNeto: $profitNeto, retencionAplicada: $retencionAplicada, method: $method, porcentajeRetencion: $porcentajeRetencion, monthlyRates: $monthlyRates, progressionPoints: $progressionPoints, monthlyBreakdown: $monthlyBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestmentResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.months, months) || other.months == months) &&
            (identical(other.totalBruto, totalBruto) ||
                other.totalBruto == totalBruto) &&
            (identical(other.totalNeto, totalNeto) ||
                other.totalNeto == totalNeto) &&
            (identical(other.profitBruto, profitBruto) ||
                other.profitBruto == profitBruto) &&
            (identical(other.profitNeto, profitNeto) ||
                other.profitNeto == profitNeto) &&
            (identical(other.retencionAplicada, retencionAplicada) ||
                other.retencionAplicada == retencionAplicada) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.porcentajeRetencion, porcentajeRetencion) ||
                other.porcentajeRetencion == porcentajeRetencion) &&
            const DeepCollectionEquality()
                .equals(other._monthlyRates, _monthlyRates) &&
            const DeepCollectionEquality()
                .equals(other._progressionPoints, _progressionPoints) &&
            const DeepCollectionEquality()
                .equals(other._monthlyBreakdown, _monthlyBreakdown));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      label,
      type,
      amount,
      rate,
      months,
      totalBruto,
      totalNeto,
      profitBruto,
      profitNeto,
      retencionAplicada,
      method,
      porcentajeRetencion,
      const DeepCollectionEquality().hash(_monthlyRates),
      const DeepCollectionEquality().hash(_progressionPoints),
      const DeepCollectionEquality().hash(_monthlyBreakdown));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestmentResultImplCopyWith<_$InvestmentResultImpl> get copyWith =>
      __$$InvestmentResultImplCopyWithImpl<_$InvestmentResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestmentResultImplToJson(
      this,
    );
  }
}

abstract class _InvestmentResult implements InvestmentResult {
  const factory _InvestmentResult(
          {required final String id,
          required final String label,
          required final InvestmentType type,
          required final double amount,
          required final double rate,
          required final int months,
          required final double totalBruto,
          required final double totalNeto,
          required final double profitBruto,
          required final double profitNeto,
          final double retencionAplicada,
          required final CalculationMethod method,
          final double porcentajeRetencion,
          required final List<double>? monthlyRates,
          required final List<double>? progressionPoints,
          required final List<Map<String, dynamic>> monthlyBreakdown}) =
      _$InvestmentResultImpl;

  factory _InvestmentResult.fromJson(Map<String, dynamic> json) =
      _$InvestmentResultImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  InvestmentType get type;
  @override
  double get amount;
  @override
  double get rate;
  @override
  int get months;
  @override
  double get totalBruto;
  @override
  double get totalNeto;
  @override
  double get profitBruto;
  @override
  double get profitNeto;
  @override
  double get retencionAplicada;
  @override
  CalculationMethod get method;
  @override
  double get porcentajeRetencion;
  @override
  List<double>? get monthlyRates;
  @override
  List<double>? get progressionPoints;
  @override
  List<Map<String, dynamic>> get monthlyBreakdown;
  @override
  @JsonKey(ignore: true)
  _$$InvestmentResultImplCopyWith<_$InvestmentResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
