
import 'package:flutter/material.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/screens/flight_details_screen.dart';
import 'package:my_itinerary/widgets/flight_overall_info.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  const FlightCard({super.key, required this.flight});


  @override
  Widget build(BuildContext context) {
    // Determine colors based on completion status
    Color cardColor = flight.isCompleted ? Colors.grey[100]! : Colors.white;
    Color textColor = flight.isCompleted ? Colors.grey[600]! : Colors.black;
    Color iconColor = flight.isCompleted ? Colors.grey[500]! : Colors.black;
    Color beanColor = flight.isCompleted ? Colors.grey[300]! : Colors.yellow;

    return Center(
      child: Opacity(
        opacity: flight.isCompleted ? 0.6 : 1.0,
        child: GestureDetector(
          onTap: () => {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FlightDetailsScreen(flight: flight))),
          },
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Card(
              elevation: flight.isCompleted ? 2 : 10,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(8.0),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //flightInfo(flight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: flightOverallInfo(flight, isArrival: false, textColor: textColor, iconColor: iconColor)),
                        Expanded(child: flightCode(flight, beanColor: beanColor, textColor: textColor)),
                        Expanded(child: flightOverallInfo(flight, isArrival: true, textColor: textColor, iconColor: iconColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}




