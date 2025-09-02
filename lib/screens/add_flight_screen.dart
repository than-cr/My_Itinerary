import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_itinerary/cache/flight_cache_manager.dart';
import 'package:my_itinerary/models/flight.dart';
import 'package:my_itinerary/services/auth_service.dart';
import 'package:my_itinerary/services/flight_service.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key});

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flightService = FlightService();
  final _flightCacheManager = FlightCacheManager();

  // Controllers for form fields
  final _flightNumberController = TextEditingController();
  final _confirmationCodeController = TextEditingController();
  final _departureAirportController = TextEditingController();
  final _departureAirportNameController = TextEditingController();
  final _arrivalAirportController = TextEditingController();
  final _arrivalAirportNameController = TextEditingController();
  final _airlineController = TextEditingController();
  final _seatNumberController = TextEditingController();
  final _terminalController = TextEditingController();
  final _gateController = TextEditingController();

  // Date and time variables - using timezone-naive DateTime objects
  late DateTime _departureDate;
  late TimeOfDay _departureTime;
  late DateTime _arrivalDate;
  late TimeOfDay _arrivalTime;

  @override
  void initState() {
    super.initState();
    // Initialize with current local time values but as timezone-naive objects
    final now = DateTime.now();
    _departureDate = DateTime(now.year, now.month, now.day);
    _departureTime = TimeOfDay.now();
    _arrivalDate = DateTime(now.year, now.month, now.day);
    
    // Calculate arrival time (2 hours later, handling day overflow)
    final arrivalHour = _departureTime.hour + 2;
    if (arrivalHour >= 24) {
      _arrivalTime = TimeOfDay(hour: arrivalHour - 24, minute: _departureTime.minute);
      _arrivalDate = DateTime(now.year, now.month, now.day + 1);
    } else {
      _arrivalTime = TimeOfDay(hour: arrivalHour, minute: _departureTime.minute);
    }
  }

  bool _isLoading = false;

  @override
  void dispose() {
    _flightNumberController.dispose();
    _confirmationCodeController.dispose();
    _departureAirportController.dispose();
    _departureAirportNameController.dispose();
    _arrivalAirportController.dispose();
    _arrivalAirportNameController.dispose();
    _airlineController.dispose();
    _seatNumberController.dispose();
    _terminalController.dispose();
    _gateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate : _arrivalDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.yellow,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _arrivalDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isDeparture ? _departureTime : _arrivalTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.yellow,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = picked;
        } else {
          _arrivalTime = picked;
        }
      });
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _saveFlight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final departureDateTime = _combineDateAndTime(_departureDate, _departureTime);
      final arrivalDateTime = _combineDateAndTime(_arrivalDate, _arrivalTime);

      // Validate that arrival is after departure
      if (!arrivalDateTime.isAfter(departureDateTime)) {
        throw Exception('Arrival time must be after departure time');
      }

      final flight = Flight(
        flightNumber: _flightNumberController.text.trim(),
        confirmationCode: _confirmationCodeController.text.trim(),
        departureAirport: _departureAirportController.text.trim().toUpperCase(),
        departureAirportName: _departureAirportNameController.text.trim(),
        arrivalAirport: _arrivalAirportController.text.trim().toUpperCase(),
        arrivalAirportName: _arrivalAirportNameController.text.trim(),
        departureTime: departureDateTime,
        arrivalTime: arrivalDateTime,
        airline: _airlineController.text.trim(),
        seatNumber: _seatNumberController.text.trim(),
        terminal: _terminalController.text.trim(),
        gate: _gateController.text.trim(),
        userId: userId,
        isCompleted: false,
      );

      await _flightService.addFlight(flight);
      
      // Invalidate cache to force refresh
      _flightCacheManager.invalidateCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flight added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        // Clean up error message by removing "Exception: " prefix
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Flight',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Flight Information Section
            _buildSectionHeader('Flight Information'),
            const SizedBox(height: 12),
            _buildTextFormField(
              controller: _flightNumberController,
              label: 'Flight Number',
              hint: 'e.g., AA123',
              required: true,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _confirmationCodeController,
              label: 'Confirmation Code',
              hint: 'e.g., ABC123',
              required: true,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _airlineController,
              label: 'Airline',
              hint: 'e.g., American Airlines',
              required: true,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 24),

            // Departure Section
            _buildSectionHeader('Departure'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _departureAirportController,
                    label: 'Airport Code',
                    hint: 'e.g., LAX',
                    required: true,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildTextFormField(
                    controller: _departureAirportNameController,
                    label: 'Airport Name',
                    hint: 'e.g., Los Angeles International',
                    required: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Departure Date',
                    value: DateFormat('MMM dd, yyyy').format(_departureDate),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Departure Time',
                    value: _departureTime.format(context),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Arrival Section
            _buildSectionHeader('Arrival'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _arrivalAirportController,
                    label: 'Airport Code',
                    hint: 'e.g., JFK',
                    required: true,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildTextFormField(
                    controller: _arrivalAirportNameController,
                    label: 'Airport Name',
                    hint: 'e.g., John F. Kennedy International',
                    required: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Arrival Date',
                    value: DateFormat('MMM dd, yyyy').format(_arrivalDate),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Arrival Time',
                    value: _arrivalTime.format(context),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Flight Details Section
            _buildSectionHeader('Flight Details'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _seatNumberController,
                    label: 'Seat Number',
                    hint: 'e.g., 12A',
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: _terminalController,
                    label: 'Terminal',
                    hint: 'e.g., Terminal 1',
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _gateController,
              label: 'Gate',
              hint: 'e.g., A12',
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveFlight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Save Flight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.yellow, width: 2),
        ),
        counterText: maxLength != null ? '' : null, // Hide counter
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (maxLength != null && value != null && value.length != maxLength) {
          return '$label must be exactly $maxLength characters';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
