import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/widgets/bean.dart';

Widget flightOverallInfo(Flight flight, {bool isArrival = false, Color? textColor, Color? iconColor, bool showIcon = true, bool showAirportName = false}) {
  IconData icon = isArrival ? Icons.flight_land : Icons.flight_takeoff;
  String airport = isArrival ? (showAirportName ? flight.arrivalAirportName : flight.arrivalAirport) : (showAirportName ? flight.departureAirportName : flight.departureAirport);
  DateTime dateTime = isArrival ? flight.arrivalTime : flight.departureTime;
  
  // Use provided colors or default to black
  Color finalTextColor = textColor ?? Colors.black;
  Color finalIconColor = iconColor ?? Colors.black;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      showIcon ? Icon(icon, size: 42, color: finalIconColor) : SizedBox.shrink(),
      SizedBox(
        width: 80, // Specify exact width for wrapping
        child: Text(airport,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: finalTextColor,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          overflow: TextOverflow.visible,
          maxLines: 2,
        ),
      ),
      SizedBox(height: 2),
      Text(
        DateFormat('dd MMM, yyyy').format(dateTime),
        style: TextStyle(fontSize: 12, color: finalTextColor),
        textAlign: TextAlign.center,
      ),
      Text(
        DateFormat('h:mm a').format(dateTime),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: finalTextColor),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget flightCode(Flight flight, {Color? beanColor, Color? textColor}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Beans for flight information
      bean(flight.flightNumber, beanColor: beanColor, textColor: textColor),
    ],
  );
}