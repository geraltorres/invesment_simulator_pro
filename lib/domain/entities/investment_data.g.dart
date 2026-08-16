// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestmentResultImpl _$$InvestmentResultImplFromJson(
        Map<String, dynamic> json) =>
    _$InvestmentResultImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      type: $enumDecode(_$InvestmentTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      months: (json['months'] as num).toInt(),
      totalBruto: (json['totalBruto'] as num).toDouble(),
      totalNeto: (json['totalNeto'] as num).toDouble(),
      profitBruto: (json['profitBruto'] as num).toDouble(),
      profitNeto: (json['profitNeto'] as num).toDouble(),
      retencionAplicada: (json['retencionAplicada'] as num?)?.toDouble() ?? 0.0,
      method: $enumDecode(_$CalculationMethodEnumMap, json['method']),
      porcentajeRetencion:
          (json['porcentajeRetencion'] as num?)?.toDouble() ?? 0.0,
      monthlyRates: (json['monthlyRates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      progressionPoints: (json['progressionPoints'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      monthlyBreakdown: (json['monthlyBreakdown'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$$InvestmentResultImplToJson(
        _$InvestmentResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': _$InvestmentTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'rate': instance.rate,
      'months': instance.months,
      'totalBruto': instance.totalBruto,
      'totalNeto': instance.totalNeto,
      'profitBruto': instance.profitBruto,
      'profitNeto': instance.profitNeto,
      'retencionAplicada': instance.retencionAplicada,
      'method': _$CalculationMethodEnumMap[instance.method]!,
      'porcentajeRetencion': instance.porcentajeRetencion,
      'monthlyRates': instance.monthlyRates,
      'progressionPoints': instance.progressionPoints,
      'monthlyBreakdown': instance.monthlyBreakdown,
    };

const _$InvestmentTypeEnumMap = {
  InvestmentType.cdt: 'cdt',
  InvestmentType.acciones: 'acciones',
  InvestmentType.fondo: 'fondo',
  InvestmentType.otro: 'otro',
};

const _$CalculationMethodEnumMap = {
  CalculationMethod.simple: 'simple',
  CalculationMethod.compuesto: 'compuesto',
};
