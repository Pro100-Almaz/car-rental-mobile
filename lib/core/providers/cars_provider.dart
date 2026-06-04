import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/resources/mobile_vehicles_api.dart';
import '../models/car.dart';

// ---------------------------------------------------------------------------
// Filter model
// ---------------------------------------------------------------------------

class CarsFilter {
  const CarsFilter({
    this.search,
    this.categories = const {},
    this.fuelTypes = const {},
    this.transmissions = const {},
    this.minPrice,
    this.maxPrice,
  });

  final String? search;
  final Set<VehicleCategory> categories;
  final Set<FuelType> fuelTypes;
  final Set<Transmission> transmissions;
  final int? minPrice;
  final int? maxPrice;

  bool get isEmpty =>
      (search == null || search!.isEmpty) &&
      categories.isEmpty &&
      fuelTypes.isEmpty &&
      transmissions.isEmpty &&
      minPrice == null &&
      maxPrice == null;

  CarsFilter copyWith({
    Object? search = _sentinel,
    Set<VehicleCategory>? categories,
    Set<FuelType>? fuelTypes,
    Set<Transmission>? transmissions,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
  }) {
    return CarsFilter(
      search: search == _sentinel ? this.search : search as String?,
      categories: categories ?? this.categories,
      fuelTypes: fuelTypes ?? this.fuelTypes,
      transmissions: transmissions ?? this.transmissions,
      minPrice: minPrice == _sentinel ? this.minPrice : minPrice as int?,
      maxPrice: maxPrice == _sentinel ? this.maxPrice : maxPrice as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarsFilter) return false;
    return search == other.search &&
        categories.length == other.categories.length &&
        categories.containsAll(other.categories) &&
        fuelTypes.length == other.fuelTypes.length &&
        fuelTypes.containsAll(other.fuelTypes) &&
        transmissions.length == other.transmissions.length &&
        transmissions.containsAll(other.transmissions) &&
        minPrice == other.minPrice &&
        maxPrice == other.maxPrice;
  }

  @override
  int get hashCode => Object.hash(
        search,
        Object.hashAll(categories),
        Object.hashAll(fuelTypes),
        Object.hashAll(transmissions),
        minPrice,
        maxPrice,
      );
}

const _sentinel = Object();

// ---------------------------------------------------------------------------
// State model
// ---------------------------------------------------------------------------

class CarsListState {
  const CarsListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loading = false,
    this.refreshing = false,
    this.errorCode,
    this.filter = const CarsFilter(),
  });

  final List<CarListing> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool refreshing;
  final String? errorCode;
  final CarsFilter filter;

  bool get hasError => errorCode != null;
  bool get isEmpty => !loading && !refreshing && items.isEmpty && !hasError;

  CarsListState copyWith({
    List<CarListing>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? refreshing,
    Object? errorCode = _sentinel,
    CarsFilter? filter,
  }) {
    return CarsListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      errorCode: errorCode == _sentinel ? this.errorCode : errorCode as String?,
      filter: filter ?? this.filter,
    );
  }
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class CarsListNotifier extends StateNotifier<CarsListState> {
  CarsListNotifier(this._ref) : super(const CarsListState()) {
    loadFirstPage();
  }

  final Ref _ref;
  Timer? _debounceTimer;

  MobileVehiclesApi get _api => _ref.read(mobileVehiclesApiProvider);

  // ---- Public API -----------------------------------------------------------

  Future<void> loadFirstPage() async {
    if (state.loading) return;
    state = state.copyWith(
      loading: true,
      page: 1,
      hasMore: true,
      errorCode: null,
      items: [],
    );
    await _fetch(page: 1, append: false);
  }

  Future<void> loadNextPage() async {
    if (state.loading || state.refreshing || !state.hasMore) return;
    state = state.copyWith(loading: true);
    await _fetch(page: state.page + 1, append: true);
  }

  Future<void> refresh() async {
    if (state.refreshing) return;
    state = state.copyWith(
      refreshing: true,
      page: 1,
      hasMore: true,
      errorCode: null,
    );
    await _fetch(page: 1, append: false);
    if (mounted) state = state.copyWith(refreshing: false);
  }

  void applyFilter(CarsFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
    loadFirstPage();
  }

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final newFilter = state.filter.copyWith(search: query);
      if (state.filter == newFilter) return;
      state = state.copyWith(filter: newFilter, page: 1, items: []);
      loadFirstPage();
    });
  }

  void resetFilter() {
    applyFilter(CarsFilter(search: state.filter.search));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ---- Private --------------------------------------------------------------

  Future<void> _fetch({required int page, required bool append}) async {
    try {
      final f = state.filter;
      final result = await _api.list(
        page: page,
        pageSize: 20,
        search: f.search,
        categories: f.categories.isEmpty ? null : f.categories,
        fuelTypes: f.fuelTypes.isEmpty ? null : f.fuelTypes,
        transmissions: f.transmissions.isEmpty ? null : f.transmissions,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
      );

      if (!mounted) return;

      final newItems =
          append ? [...state.items, ...result.items] : result.items;

      state = state.copyWith(
        items: newItems,
        page: result.page,
        hasMore: result.hasMore,
        loading: false,
        refreshing: false,
        errorCode: null,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        refreshing: false,
        errorCode: e.code,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        refreshing: false,
        errorCode: 'unknown',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final carsListProvider =
    StateNotifierProvider<CarsListNotifier, CarsListState>((ref) {
  return CarsListNotifier(ref);
});

/// Family provider for a single car detail — used by CarDetailScreen
final carDetailProvider =
    FutureProvider.family<CarListing, String>((ref, carId) async {
  return ref.read(mobileVehiclesApiProvider).get(carId);
});

// ---------------------------------------------------------------------------
// Availability cache provider
// Key: (vehicleId, year, month)
// ---------------------------------------------------------------------------

typedef AvailKey = ({String vehicleId, int year, int month});

final availabilityProvider = FutureProvider.family<
    Map<DateTime, DayAvailability>, AvailKey>((ref, key) async {
  return ref.read(mobileVehiclesApiProvider).availability(
        key.vehicleId,
        DateTime(key.year, key.month),
      );
});

// Helper to build the key
AvailKey availKey(String vehicleId, DateTime month) =>
    (vehicleId: vehicleId, year: month.year, month: month.month);
