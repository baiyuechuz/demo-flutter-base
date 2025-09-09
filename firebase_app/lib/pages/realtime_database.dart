import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class RealtimeDatabasePage extends StatefulWidget {
  const RealtimeDatabasePage({super.key});

  @override
  State<RealtimeDatabasePage> createState() => _RealtimeDatabasePageState();
}

class _RealtimeDatabasePageState extends State<RealtimeDatabasePage> {
  final database = FirebaseDatabase.instance;
  late DatabaseReference _counterRef;
  late DatabaseReference _messagesRef;

  int _counter = 0;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;
  StreamSubscription? _counterSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _connectedSubscription;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeRealtime();
  }

  @override
  void dispose() {
    _counterSubscription?.cancel();
    _messagesSubscription?.cancel();
    _connectedSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeRealtime() async {
    setState(() => _isLoading = true);

    try {
      _counterRef = database.ref('demo/counter');
      _messagesRef = database.ref('demo/messages');

      await _setupRealtimeSubscriptions();
      await _checkConnectionStatus();

      setState(() => _isConnected = true);
    } catch (error) {
      _showSnackBar('Error connecting to real-time: $error', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupRealtimeSubscriptions() async {
    _counterSubscription = _counterRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        _counter = data is int ? data : 0;
      });
    });

    _messagesSubscription = _messagesRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final messages = <Map<String, dynamic>>[];
        data.forEach((key, value) {
          if (value is Map) {
            messages.add({
              'id': key,
              'text': value['text'] ?? '',
              'timestamp': value['timestamp'] ?? 0,
            });
          }
        });
        messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        setState(() {
          _messages = messages;
        });
      } else {
        setState(() {
          _messages = [];
        });
      }
    });
  }

  Future<void> _checkConnectionStatus() async {
    final connectedRef = database.ref('.info/connected');
    _connectedSubscription = connectedRef.onValue.listen((DatabaseEvent event) {
      final connected = event.snapshot.value as bool? ?? false;
      setState(() {
        _isConnected = connected;
      });
    });
  }

  Future<void> _incrementCounter() async {
    try {
      await _counterRef.set(_counter + 1);
    } catch (error) {
      _showSnackBar('Error updating counter: $error', Colors.red);
    }
  }

  Future<void> _decrementCounter() async {
    try {
      await _counterRef.set(_counter - 1);
    } catch (error) {
      _showSnackBar('Error updating counter: $error', Colors.red);
    }
  }

  Future<void> _resetCounter() async {
    try {
      await _counterRef.set(0);
    } catch (error) {
      _showSnackBar('Error resetting counter: $error', Colors.red);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _messagesRef.push().set({
        'text': _messageController.text.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _messageController.clear();
    } catch (error) {
      _showSnackBar('Error sending message: $error', Colors.red);
    }
  }

  Future<void> _clearMessages() async {
    try {
      await _messagesRef.remove();
    } catch (error) {
      _showSnackBar('Error clearing messages: $error', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real-time Database',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0b1221),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0b1221),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.sync, color: Colors.white, size: 60),
                        const SizedBox(height: 10),
                        const Text(
                          'Real-time Data Sync',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Get and set data that syncs instantly with Firebase Realtime Database',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isConnected
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isConnected ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isConnected ? Icons.wifi : Icons.wifi_off,
                                color: _isConnected ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isConnected
                                    ? 'Real-time Connected'
                                    : 'Disconnected',
                                style: TextStyle(
                                  color: _isConnected
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCounterSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCounterSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Real-time Counter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF374151), Color(0xFF4B5563)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              _counter.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                color: Colors.red,
                onPressed: _decrementCounter,
                label: 'Decrease',
              ),
              _buildCounterButton(
                icon: Icons.refresh,
                color: Colors.orange,
                onPressed: _resetCounter,
                label: 'Reset',
              ),
              _buildCounterButton(
                icon: Icons.add,
                color: Colors.green,
                onPressed: _incrementCounter,
                label: 'Increase',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            iconSize: 32,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
