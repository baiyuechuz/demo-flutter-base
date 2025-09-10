import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeDatabasePage extends StatefulWidget {
  const RealtimeDatabasePage({super.key});

  @override
  State<RealtimeDatabasePage> createState() => _RealtimeDatabasePageState();
}

class _RealtimeDatabasePageState extends State<RealtimeDatabasePage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic> _realtimeData = {};
  bool _isLoading = false;
  bool _isConnected = false;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _initializeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _initializeRealtime() async {
    setState(() => _isLoading = true);

    try {
      // Fetch existing data
      await _fetchData();

      // Set up real-time subscription
      _setupRealtimeSubscription();

      setState(() => _isConnected = true);
    } catch (error) {
      _showSnackBar('Error connecting to real-time: $error', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase
          .from('realtime_data')
          .select()
          .order('updated_at', ascending: false)
          .limit(10);

      setState(() {
        _realtimeData = {};
        for (var item in response) {
          _realtimeData[item['key']] = item;
        }
      });
    } catch (error) {
      _showSnackBar('Error fetching data: $error', Colors.red);
    }
  }

  void _setupRealtimeSubscription() {
    _channel = supabase
        .channel('realtime_data_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'realtime_data',
          callback: (payload) {
            final newData = payload.newRecord;
            setState(() {
              _realtimeData[newData['key']] = newData;
            });
            _showSnackBar(
              'New data: ${newData['key']} = ${newData['value']}',
              Colors.green,
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'realtime_data',
          callback: (payload) {
            final updatedData = payload.newRecord;
            setState(() {
              _realtimeData[updatedData['key']] = updatedData;
            });
            _showSnackBar(
              'Updated: ${updatedData['key']} = ${updatedData['value']}',
              Colors.blue,
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'realtime_data',
          callback: (payload) {
            final deletedKey = payload.oldRecord['key'];
            setState(() {
              _realtimeData.remove(deletedKey);
            });
            _showSnackBar('Deleted: $deletedKey', Colors.orange);
          },
        )
        .subscribe();
  }

  Future<void> _updateCounter(String newValue) async {
    try {
      // Check if counter exists
      final existing = await supabase
          .from('realtime_data')
          .select()
          .eq('key', 'counter')
          .maybeSingle();

      if (existing != null) {
        // Update existing
        await supabase
            .from('realtime_data')
            .update({
              'value': newValue,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('key', 'counter');
      } else {
        // Insert new
        await supabase.from('realtime_data').insert({
          'key': 'counter',
          'value': newValue,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (error) {
      _showSnackBar('Error updating counter: $error', Colors.red);
    }
  }

  Future<void> _incrementCounter() async {
    final currentData = _realtimeData['counter'];
    final currentValue =
        int.tryParse(currentData?['value']?.toString() ?? '0') ?? 0;
    final newValue = currentValue + 1;

    await _updateCounter(newValue.toString());
  }

  Future<void> _decrementCounter() async {
    final currentData = _realtimeData['counter'];
    final currentValue =
        int.tryParse(currentData?['value']?.toString() ?? '0') ?? 0;
    final newValue = currentValue - 1;

    await _updateCounter(newValue.toString());
  }

  Future<void> _resetCounter() async {
    await _updateCounter('0');
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
          'Real-time Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0b1221),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0b1221),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Section
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
                        'Get and set data that syncs instantly across all devices',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Connection Status
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
                                color: _isConnected ? Colors.green : Colors.red,
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

                // Counter Demo Section
                Flexible(child: _buildCounterSection()),
              ],
            ),
    );
  }

  Widget _buildCounterSection() {
    final counterData = _realtimeData['counter'];
    final counterValue =
        int.tryParse(counterData?['value']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Real-time Counter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          // Counter Display
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF374151), const Color(0xFF4B5563)],
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
              counterValue.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Counter Controls
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
