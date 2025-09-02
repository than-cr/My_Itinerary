import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/services/auth_service.dart';

class FlightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'flights';

  Future<String> addFlight(Flight flight) async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add userId to flight data before saving
      final flightData = flight.toJson();
      flightData['userId'] = userId;

      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(flightData);
      return docRef.id;
    } catch (e) {
      //throw Exception('Failed to add flight: $e');
      throw Exception('Failed to add flight');
    }
  }

  Future<List<Flight>> getAllFlights() async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return Flight.fromJson(data);
      }).toList()..sort((a, b) => a.departureTime.compareTo(b.departureTime));
    } catch (e) {
      //throw Exception('Failed to fetch flights: $e');
      throw Exception('Failed to fetch flights');
    }
  }

  Future<String> markFlightAsCompleted(String flightId) async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First verify the flight belongs to the current user
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(flightId)
          .get();
      if (!doc.exists) {
        throw Exception('Flight not found');
      }

      final flightData = doc.data() as Map<String, dynamic>;
      if (flightData['userId'] != userId) {
        throw Exception('Unauthorized: Flight does not belong to current user');
      }

      await _firestore.collection(_collectionName).doc(flightId).update({
        'isCompleted': true,
      });
      return 'Flight marked as completed';
    } catch (e) {
      //throw Exception('Failed to mark flight as completed: $e');
      throw Exception('Failed to mark flight as completed');
    }
  }

  // Get only active flights for the current user
  Future<List<Flight>> getActiveFlights() async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Flight.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch active flights');
    }
  }

  // Get only completed flights for the current user
  Future<List<Flight>> getCompletedFlights() async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Flight.fromJson(data);
      }).toList()..sort((a, b) => a.departureTime.compareTo(b.departureTime));
    } catch (e) {
      throw Exception('Failed to fetch completed flights');
    }
  }

  // Delete a flight (only if it belongs to current user)
  Future<String> deleteFlight(String flightId) async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First verify the flight belongs to the current user
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(flightId)
          .get();
      if (!doc.exists) {
        throw Exception('Flight not found');
      }

      final flightData = doc.data() as Map<String, dynamic>;
      if (flightData['userId'] != userId) {
        throw Exception('Unauthorized: Flight does not belong to current user');
      }

      await _firestore.collection(_collectionName).doc(flightId).delete();
      return 'Flight deleted successfully';
    } catch (e) {
      throw Exception('Failed to delete flight');
    }
  }

  // Update a flight (only if it belongs to current user)
  Future<String> updateFlight(String flightId, Flight updatedFlight) async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First verify the flight belongs to the current user
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(flightId)
          .get();
      if (!doc.exists) {
        throw Exception('Flight not found');
      }

      final flightData = doc.data() as Map<String, dynamic>;
      if (flightData['userId'] != userId) {
        throw Exception('Unauthorized: Flight does not belong to current user');
      }

      // Ensure userId is preserved in the update
      final updateData = updatedFlight.toJson();
      updateData['userId'] = userId;

      await _firestore
          .collection(_collectionName)
          .doc(flightId)
          .update(updateData);
      return 'Flight updated successfully';
    } catch (e) {
      throw Exception('Failed to update flight');
    }
  }
}
