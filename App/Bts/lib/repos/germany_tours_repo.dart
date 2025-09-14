import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/germany_tour_package.dart';

class GermanyToursRepo {
  List<GermanyTourPackage>? _cachedTours;

  Future<List<GermanyTourPackage>> getGermanyTours() async {
    if (_cachedTours != null) {
      return _cachedTours!;
    }

    try {
      final String jsonString = await rootBundle.loadString('data/Italy_Germany_tours.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final allTours = jsonList
          .map((json) => GermanyTourPackage.fromJson(json as Map<String, dynamic>))
          .where((tour) => _isGermanDestination(tour.location))
          .where((tour) => _isValidTour(tour))
          .toList();

      _cachedTours = allTours;
      return allTours;
    } catch (e) {
      throw Exception('Failed to load Germany tours: $e');
    }
  }

  List<GermanyTourPackage> filterByLocation(List<GermanyTourPackage> tours, String location) {
    return tours.where((tour) => tour.location.toLowerCase() == location.toLowerCase()).toList();
  }

  bool _isGermanDestination(String location) {
    const germanCities = ['Berlin', 'Munich'];
    return germanCities.any((city) => location.toLowerCase() == city.toLowerCase());
  }

  bool _isValidTour(GermanyTourPackage tour) {
    return tour.id.isNotEmpty &&
           tour.name.isNotEmpty &&
           tour.images.isNotEmpty &&
           tour.priceEur.isNotEmpty;
  }

  void clearCache() {
    _cachedTours = null;
  }
}