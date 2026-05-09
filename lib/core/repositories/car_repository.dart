import '../../features/home/data/sample_cars.dart';

abstract class CarRepository {
  List<CarListing> getAllCars();
  CarListing? getCarById(String id);
  List<CarListing> getCarsByCategory(String category);
  List<CarListing> getNearbyCars();
  List<CarListing> getTopRated();
}

class MockCarRepository implements CarRepository {
  final List<CarListing> _allCars = [...kNearbyCars, ...kTopRated];

  @override
  List<CarListing> getAllCars() => _allCars;

  @override
  CarListing? getCarById(String id) {
    try {
      return _allCars.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<CarListing> getCarsByCategory(String category) {
    if (category == 'all') return _allCars;
    return _allCars.where((c) => c.category == category).toList();
  }

  @override
  List<CarListing> getNearbyCars() => List.of(kNearbyCars);

  @override
  List<CarListing> getTopRated() => List.of(kTopRated);
}
