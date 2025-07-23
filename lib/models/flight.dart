import 'package:cloud_firestore/cloud_firestore.dart';

class Flight {
  final String? id;
  final String flightNumber;
  final String confirmationCode;
  final String departureAirport;
  final String departureAirportName;
  final String arrivalAirport;
  final String arrivalAirportName;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String airline;
  final String seatNumber;
  final String terminal;
  final String gate;
  final String userId;
  final bool isCompleted;

  Flight({
    this.id,
    required this.flightNumber,
    required this.confirmationCode,
    required this.departureAirport,
    required this.departureAirportName,
    required this.arrivalAirport,
    required this.arrivalAirportName,
    required this.departureTime,
    required this.arrivalTime,
    required this.airline,
    required this.seatNumber,
    required this.terminal,
    required this.gate,
    required this.userId, // Added userId to associate flight with user
    required this.isCompleted,
  });

  Flight.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '', // Assuming 'id' is included in the JSON or default to empty string
        flightNumber = json['flightNumber'],
        confirmationCode = json['confirmationCode'],
        departureAirport = json['departureAirport'],
        departureAirportName = json['departureAirportName'],
        arrivalAirport = json['arrivalAirport'],
        arrivalAirportName = json['arrivalAirportName'],
        departureTime = _parseDateTime(json['departureTime']),
        arrivalTime = _parseDateTime(json['arrivalTime']),
        airline = json['airline'],
        seatNumber = json['seatNumber'],
        terminal = json['terminal'],
        gate = json['gate'],
        userId = json['userId'],
        isCompleted = json['isCompleted'] ?? false;

  // Helper method to parse DateTime from different formats without timezone conversion
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is Map<String, dynamic>) {
      // Our custom format: stored as separate date components
      return DateTime(
        dateTime['year'] ?? 0,
        dateTime['month'] ?? 1,
        dateTime['day'] ?? 1,
        dateTime['hour'] ?? 0,
        dateTime['minute'] ?? 0,
        dateTime['second'] ?? 0,
        dateTime['millisecond'] ?? 0,
      );
    } else if (dateTime is Timestamp) {
      // Legacy Firestore Timestamp - extract components to avoid timezone conversion
      final dt = dateTime.toDate().toLocal();
      return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond);
    } else if (dateTime is int) {
      // Legacy milliseconds - extract components to avoid timezone interpretation
      final dt = DateTime.fromMillisecondsSinceEpoch(dateTime).toLocal();
      return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond);
    } else if (dateTime is String) {
      // ISO string - parse and extract components only
      try {
        final parsed = DateTime.parse(dateTime);
        return DateTime(parsed.year, parsed.month, parsed.day, parsed.hour, parsed.minute, parsed.second, parsed.millisecond);
      } catch (e) {
        throw FormatException('Invalid date string format: $dateTime');
      }
    } else if (dateTime is DateTime) {
      // Already a DateTime - extract components to ensure no timezone data
      return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute, dateTime.second, dateTime.millisecond);
    } else {
      throw FormatException('Unknown dateTime format: ${dateTime.runtimeType}');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'flightNumber': flightNumber,
      'confirmationCode': confirmationCode,
      'departureAirport': departureAirport,
      'departureAirportName': departureAirportName,
      'arrivalAirport': arrivalAirport,
      'arrivalAirportName': arrivalAirportName,
      // Store as separate date components to completely avoid timezone conversion
      'departureTime': {
        'year': departureTime.year,
        'month': departureTime.month,
        'day': departureTime.day,
        'hour': departureTime.hour,
        'minute': departureTime.minute,
        'second': departureTime.second,
        'millisecond': departureTime.millisecond,
      },
      'arrivalTime': {
        'year': arrivalTime.year,
        'month': arrivalTime.month,
        'day': arrivalTime.day,
        'hour': arrivalTime.hour,
        'minute': arrivalTime.minute,
        'second': arrivalTime.second,
        'millisecond': arrivalTime.millisecond,
      },
      'airline': airline,
      'seatNumber': seatNumber,
      'terminal': terminal,
      'gate': gate,
      'userId': userId, // Include userId to associate flight with user
      'isCompleted': isCompleted,
    };
    
    // Only include id if it's not null
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }
}