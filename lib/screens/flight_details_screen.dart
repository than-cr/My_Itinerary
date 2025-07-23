import 'package:flutter/material.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/widgets/flight_card.dart';

class FlightDetailsScreen extends StatelessWidget {
  final Flight flight;

  const FlightDetailsScreen({
    super.key, 
    required this.flight
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Flight Details',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: flightCard(context, flight: flight),
    );
  }
}

