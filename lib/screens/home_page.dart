import 'package:flutter/material.dart';
import 'package:my_itinerary/cache/flight_cache_manager.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/screens/add_flight_screen.dart';
import 'package:my_itinerary/screens/auth_screen.dart';
import 'package:my_itinerary/screens/flight_card.dart';
import 'package:my_itinerary/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final flightCacheManager = FlightCacheManager();
  List<Flight> _activeFlights = [];
  List<Flight> _completedFlights = [];
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _loadFlights({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (forceRefresh) {
        flightCacheManager.invalidateCache();
      }

      await flightCacheManager.getFlights();

      setState(() {
        _activeFlights = flightCacheManager.getActiveFlights();
        _completedFlights = flightCacheManager.getCompletedFlights();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load flights. Please check your connection and try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure Firebase is fully initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadFlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Itinerary',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _loadFlights(forceRefresh: true);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (value) async {
              switch (value) {
                case 'add_flight':
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFlightScreen(),
                    ),
                  );
                  // If a flight was successfully added, refresh the list
                  if (result == true) {
                    _loadFlights(forceRefresh: true);
                  }
                  break;
                case 'sign_out':
                  try {
                    await AuthService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to sign out. Please try again.'),
                      ),
                    );
                  }
                  break;
                default:
                  // Handle other menu options if needed
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_flight',
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.black),
                    SizedBox(height: 8),
                    Text('New Flight', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sign_out',
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(height: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading flights...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
              onPressed: () => _loadFlights(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadFlights(forceRefresh: true),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Your Flights',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const Text(
                    'Active Flights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._activeFlights.map(
                    (flight) => FlightCard(
                      flight: flight,
                      onFlightCompleted: () => _loadFlights(forceRefresh: true),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Completed Flights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._completedFlights.map(
                    (flight) => FlightCard(
                      flight: flight,
                      onFlightCompleted: () => _loadFlights(forceRefresh: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
