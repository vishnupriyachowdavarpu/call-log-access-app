import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Add a named 'key' parameter
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Log Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CallLogScreen(),
    );
  }
}

class CallLogScreen extends StatefulWidget {
  // Add a named 'key' parameter
  const CallLogScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadCallLogs();
  }

  Future<void> _checkPermissionsAndLoadCallLogs() async {
    if (await Permission.phone.request().isGranted) {
      await _getCallLogs();
    } else {
      // Handle case where permissions are denied
      // You may want to show a dialog or navigate to settings
      // ignore: avoid_print
      print('Phone permission is denied.');
    }
  }

  Future<void> _getCallLogs() async {
    try {
      Iterable<CallLogEntry> entries = await CallLog.get();
      setState(() {
        _callLogs = entries.toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching call logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Log Viewer'),
      ),
      body: _callLogs.isEmpty
          ? const Center(
              child: Text('No call logs available.'),
            )
          : ListView.builder(
              itemCount: _callLogs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_callLogs[index].name ?? 'Unknown'),
                  subtitle: Text(
                    'Number: ${_callLogs[index].number}\n'
                    'Type: ${_getCallTypeText(_callLogs[index].callType)}\n'
                    'Duration: ${_callLogs[index].duration} seconds\n'
                    'Timestamp: ${_formatTimestamp(_callLogs[index].timestamp)}',
                  ),
                );
              },
            ),
    );
  }

  String _getCallTypeText(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
      case CallType.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _formatTimestamp(timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
