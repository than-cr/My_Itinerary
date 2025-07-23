import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimezoneTestScreen extends StatefulWidget {
  const TimezoneTestScreen({super.key});

  @override
  State<TimezoneTestScreen> createState() => _TimezoneTestScreenState();
}

class _TimezoneTestScreenState extends State<TimezoneTestScreen> {
  DateTime _selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Date Storage Test',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Device Info
            _buildSectionHeader('Device Information'),
            const SizedBox(height: 12),
            _buildInfoCard([
              'Device Timezone: ${DateTime.now().timeZoneName}',
              'Device Offset: ${DateTime.now().timeZoneOffset}',
              'Current Local Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
            ]),
            
            const SizedBox(height: 24),
            
            // Test DateTime Selection
            _buildSectionHeader('Test DateTime'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
              child: Text('Select Test DateTime: ${DateFormat('MMM dd, yyyy h:mm a').format(_selectedDateTime)}'),
            ),
            
            const SizedBox(height: 24),
            
            // Storage Information
            _buildSectionHeader('How This DateTime Would Be Stored'),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildStorageCard('Local DateTime', _selectedDateTime.toString()),
                  _buildStorageCard('Milliseconds Since Epoch', _selectedDateTime.millisecondsSinceEpoch.toString()),
                  _buildStorageCard('UTC Conversion (avoid this)', _selectedDateTime.toUtc().toString()),
                  _buildStorageCard('ISO String', _selectedDateTime.toIso8601String()),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('How It Would Be Retrieved'),
                  const SizedBox(height: 8),
                  _buildStorageCard(
                    'From Milliseconds', 
                    DateTime.fromMillisecondsSinceEpoch(_selectedDateTime.millisecondsSinceEpoch).toString()
                  ),
                  _buildStorageCard(
                    'Formatted for Display', 
                    DateFormat('MMM dd, yyyy h:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(_selectedDateTime.millisecondsSinceEpoch)
                    )
                  ),
                  
                  const SizedBox(height: 16),
                  _buildInfoCard([
                    'Key Point: By storing as milliseconds, we avoid timezone conversion.',
                    'The date/time remains exactly as the user entered it.',
                    'This is ideal for flight schedules where times are typically',
                    'already in the local timezone of the departure/arrival airport.',
                  ]),
                ],
              ),
            ),
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

  Widget _buildInfoCard(List<String> info) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: info.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildStorageCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
