import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../repos/models/german_station.dart';

class StationService {
  static StationService? _instance;
  static StationService get instance => _instance ??= StationService._();

  StationService._();

  List<GermanStation>? _stations;
  bool _isLoaded = false;

  /// Load German stations from JSON asset
  Future<void> loadStations() async {
    if (_isLoaded && _stations != null) return;

    try {
      final String jsonString = await rootBundle.loadString('data/80_Germany.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _stations = jsonList
          .map((json) => GermanStation.fromJson(json as Map<String, dynamic>))
          .where((station) => station.latitude != 0.0 && station.longitude != 0.0) // Filter out stations without coordinates
          .toList();

      _isLoaded = true;
    } catch (e) {
      // Handle error silently in production, could use proper logging here
      _stations = [];
    }
  }

  /// Get all German stations
  Future<List<GermanStation>> getAllStations() async {
    await loadStations();
    return _stations ?? [];
  }

  /// Get stations for dropdown display (sorted by English name)
  Future<List<GermanStation>> getStationsForDropdown() async {
    final stations = await getAllStations();
    final validStations = stations
        .where((station) => station.enName.isNotEmpty)
        .toList();

    validStations.sort((a, b) => a.enName.compareTo(b.enName));
    return validStations;
  }

  /// Find the nearest station to given coordinates
  Future<GermanStation?> findNearestStation(double latitude, double longitude) async {
    final stations = await getAllStations();
    if (stations.isEmpty) return null;

    GermanStation? nearestStation;
    double minDistance = double.infinity;

    for (final station in stations) {
      final distance = calculateHaversineDistance(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = station;
      }
    }

    return nearestStation;
  }

  /// Find stations by name (partial matching)
  Future<List<GermanStation>> searchStationsByName(String query) async {
    if (query.isEmpty) return [];

    final stations = await getAllStations();
    final queryLower = query.toLowerCase();

    return stations
        .where((station) =>
            station.enName.toLowerCase().contains(queryLower) ||
            station.name.toLowerCase().contains(queryLower))
        .toList();
  }

  /// Search departure stations with distance filtering and name matching
  /// Returns stations that match the query and are within 300km of destination
  Future<List<GermanStation>> searchFilteredDepartureStations(
    String query,
    GermanStation? destinationStation,
  ) async {
    if (query.isEmpty) return [];

    if (destinationStation == null) {
      // If no destination is set, search all stations
      return searchStationsByName(query);
    }

    // Get stations within 300 km radius of the destination
    const double maxDistanceKm = 300.0;
    final filteredStations = await getStationsWithinRadius(
      destinationStation.latitude,
      destinationStation.longitude,
      maxDistanceKm,
    );

    // Filter by search query
    final queryLower = query.toLowerCase();
    final searchResults = filteredStations
        .where((station) =>
            station.enName.isNotEmpty &&
            (station.enName.toLowerCase().contains(queryLower) ||
             station.name.toLowerCase().contains(queryLower)))
        .toList();

    // Sort by relevance: exact matches first, then alphabetical
    searchResults.sort((a, b) {
      final aEnNameLower = a.enName.toLowerCase();
      final bEnNameLower = b.enName.toLowerCase();

      // Exact matches at the beginning
      final aExactMatch = aEnNameLower.startsWith(queryLower);
      final bExactMatch = bEnNameLower.startsWith(queryLower);

      if (aExactMatch && !bExactMatch) return -1;
      if (!aExactMatch && bExactMatch) return 1;

      // Otherwise, sort alphabetically
      return aEnNameLower.compareTo(bEnNameLower);
    });

    // Limit results to avoid overwhelming the UI
    return searchResults.take(10).toList();
  }

  /// Find station by exact station code
  Future<GermanStation?> getStationByCode(String stationCode) async {
    final stations = await getAllStations();
    return stations
        .where((station) => station.stationCode == stationCode)
        .firstOrNull;
  }

  /// Calculate haversine distance between two coordinates in kilometers
  static double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    final double lat1Rad = lat1 * (pi / 180);
    final double lon1Rad = lon1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double lon2Rad = lon2 * (pi / 180);

    // Calculate differences
    final double deltaLat = lat2Rad - lat1Rad;
    final double deltaLon = lon2Rad - lon1Rad;

    // Haversine formula
    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Get stations within a specified radius (in km) from a target location
  /// Used to filter departure stations within practical range of destination
  Future<List<GermanStation>> getStationsWithinRadius(
    double targetLatitude,
    double targetLongitude,
    double radiusKm,
  ) async {
    final stations = await getAllStations();

    return stations.where((station) {
      final distance = calculateHaversineDistance(
        targetLatitude,
        targetLongitude,
        station.latitude,
        station.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Get departure stations filtered to those within 300km of destination station
  /// This ensures reasonable train route connections
  Future<List<GermanStation>> getFilteredDepartureStations(GermanStation? destinationStation) async {
    if (destinationStation == null) {
      // If no destination is set, return all stations for dropdown
      return getStationsForDropdown();
    }

    // Get stations within 300 km radius of the destination
    const double maxDistanceKm = 300.0;
    final filteredStations = await getStationsWithinRadius(
      destinationStation.latitude,
      destinationStation.longitude,
      maxDistanceKm,
    );

    // Sort by English name for consistent display
    final validStations = filteredStations
        .where((station) => station.enName.isNotEmpty)
        .toList();

    validStations.sort((a, b) => a.enName.compareTo(b.enName));
    return validStations;
  }

  /// Get major German cities (useful for testing)
  Future<List<GermanStation>> getMajorCityStations() async {
    final stations = await getAllStations();
    final majorCities = ['Berlin', 'Munich', 'Frankfurt', 'Hamburg', 'Cologne', 'Stuttgart', 'Dresden', 'Nuremberg'];

    return stations
        .where((station) => majorCities.any((city) => station.enName.toLowerCase().contains(city.toLowerCase())))
        .toList();
  }
}