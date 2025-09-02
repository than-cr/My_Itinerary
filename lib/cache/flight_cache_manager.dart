import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/services/flight_service.dart';

class FlightCacheManager {
  static final FlightCacheManager _instance = FlightCacheManager._internal();
  factory FlightCacheManager() => _instance;
  FlightCacheManager._internal();

  List<Flight>? _cachedFlights;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 10);

  bool get isCacheValid {
    if (_cachedFlights == null || _lastFetchTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<List<Flight>> getFlights() async {
    if (isCacheValid) {
      return _cachedFlights!;
    }

    try {
      final flightService = FlightService();
      _cachedFlights = await flightService.getAllFlights();
      _lastFetchTime = DateTime.now();
      return _cachedFlights!;
    } catch (e) {
      // If Firebase is not initialized, return empty list and rethrow error
      throw Exception('Unable to load flights. Please check your connection.');
    }
  }

  void invalidateCache() {
    _cachedFlights = null;
    _lastFetchTime = null;
  }

  List<Flight> getActiveFlights() {
    return _cachedFlights?.where((flight) => !flight.isCompleted).toList() ??
        [];
  }

  List<Flight> getCompletedFlights() {
    return _cachedFlights?.where((flight) => flight.isCompleted).toList() ?? [];
  }
}
