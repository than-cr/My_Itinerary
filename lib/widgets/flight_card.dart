import 'package:flutter/material.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/services/flight_service.dart';
import 'package:my_itinerary/widgets/flight_overall_info.dart';
import 'package:my_itinerary/widgets/mini_card.dart';

Widget flightCard(BuildContext context, {required Flight flight}) {
  return Column(
    children: [
      flightNumber(flight),
      flightLocations(context, flight),
      flightDetails(context, flight),
      flightCompletedButton(context, flight),
    ],
  );
}

Widget flightNumber(Flight flight) {
  return SizedBox(
    width: double.infinity,
    height: 100,
    child: Card(
      color: Colors.white,
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            airplaneIcon(30),
            SizedBox(width: 100),
            Column(
              children: [
                Text(
                  flight.flightNumber,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  flight.airline,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget airplaneIcon(double size) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Icon(Icons.flight_takeoff, size: size, color: Colors.black),
  );
}

Widget flightLocations(BuildContext context, Flight flight) {
  double deviceWidth = MediaQuery.of(context).size.width;

  return SizedBox(
    width: double.infinity,
    height: 200,
    child: Card(
      color: Colors.white,
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                flightOverallInfo(
                  flight,
                  isArrival: false,
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  showIcon: false,
                  showAirportName: true,
                ),
                Container(
                  color: Colors.grey,
                  width: deviceWidth * 0.1,
                  height: 2,
                ),
                Icon(Icons.flight_takeoff, size: 42, color: Colors.black),
                Container(
                  color: Colors.grey,
                  width: deviceWidth * 0.1,
                  height: 2,
                ),
                flightOverallInfo(
                  flight,
                  isArrival: true,
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  showIcon: false,
                  showAirportName: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: deviceWidth * 0.8,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      color: Colors.black,
                      size: 24,
                    ),
                    Text(
                      'Duration: ${flight.arrivalTime.difference(flight.departureTime).inHours}h ${flight.arrivalTime.difference(flight.departureTime).inMinutes % 60}m',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget flightDetails(BuildContext context, Flight flight) {
  double width = MediaQuery.of(context).size.width / 3;
  double height = 150;
  double iconSize = 42;
  double titleSize = 14;
  double valueSize = 16;

  return SizedBox(
    width: double.infinity,
    height: 400,
    child: Card(
      color: Colors.white,
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                miniCard(
                  title: 'Reservation',
                  value: flight.confirmationCode,
                  icon: Icons.airplane_ticket,
                  width: width,
                  height: height,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  valueSize: valueSize,
                  backgroundColor: Colors.orange[100],
                  iconColor: Colors.orange,
                ),
                miniCard(
                  title: 'Gate',
                  value: flight.gate,
                  icon: Icons.door_back_door,
                  width: width,
                  height: height,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  valueSize: valueSize,
                  backgroundColor: Colors.green[100],
                  iconColor: Colors.green,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                miniCard(
                  title: 'Terminal',
                  value: flight.terminal,
                  icon: Icons.local_airport,
                  width: width,
                  height: height,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  valueSize: valueSize,
                  backgroundColor: Colors.red[100],
                  iconColor: Colors.red,
                ),
                miniCard(
                  title: 'Seat',
                  value: flight.seatNumber,
                  icon: Icons.chair_rounded,
                  width: width,
                  height: height,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  valueSize: valueSize,
                  backgroundColor: Colors.blue[100],
                  iconColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget flightCompletedButton(BuildContext context, Flight flight) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: Padding(
      padding: EdgeInsetsGeometry.all(8.0),
      child: ElevatedButton(
        onPressed: flight.isCompleted == true
            ? null
            : () async {
                try {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marking flight as completed...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  await FlightService().markFlightAsCompleted(flight.id!);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flight marked as completed!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Pop with result to indicate the flight was completed
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to mark flight as completed. Please try again.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: flight.isCompleted == true
              ? Colors.grey
              : Colors.yellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          flight.isCompleted == true ? 'Completed' : 'Mark as Completed',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
