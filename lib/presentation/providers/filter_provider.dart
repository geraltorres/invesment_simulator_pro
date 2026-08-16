// presentation/providers/filter_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/investment_data.dart';

part 'filter_provider.g.dart';

@riverpod
class SearchFilter extends _$SearchFilter {
  @override
  String build() => "";

  void update(String value) => state = value;
  void clear() => state = "";
}

@riverpod
class TypeFilter extends _$TypeFilter {
  @override
  InvestmentType? build() => null;

  void update(InvestmentType? value) => state = value;
}
