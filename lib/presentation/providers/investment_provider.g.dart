// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSimulationsHash() =>
    r'e5bc8f5461c532a8b77c5a19cce4f249577e9fe9';

/// See also [filteredSimulations].
@ProviderFor(filteredSimulations)
final filteredSimulationsProvider =
    AutoDisposeProvider<List<InvestmentResult>>.internal(
  filteredSimulations,
  name: r'filteredSimulationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSimulationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredSimulationsRef = AutoDisposeProviderRef<List<InvestmentResult>>;
String _$portfolioSummaryHash() => r'4d656db24c8a3a20e9c06032d844554c60e668c1';

/// See also [portfolioSummary].
@ProviderFor(portfolioSummary)
final portfolioSummaryProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  portfolioSummary,
  name: r'portfolioSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$portfolioSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PortfolioSummaryRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$investmentControllerHash() =>
    r'e78966d9206ed2f743fa01a9423c2c10719b42bf';

/// See also [InvestmentController].
@ProviderFor(InvestmentController)
final investmentControllerProvider = AutoDisposeAsyncNotifierProvider<
    InvestmentController, List<InvestmentResult>>.internal(
  InvestmentController.new,
  name: r'investmentControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$investmentControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InvestmentController
    = AutoDisposeAsyncNotifier<List<InvestmentResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
