import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  Future<Map<String, dynamic>> fetchRealtimeData() async {
    try {
      final response = await _supabase
          .from('realtime_data')
          .select()
          .order('updated_at', ascending: false)
          .limit(10);

      final Map<String, dynamic> dataMap = {};
      for (var item in response) {
        dataMap[item['key']] = item;
      }
      return dataMap;
    } catch (error) {
      throw Exception('Failed to fetch realtime data: $error');
    }
  }

  RealtimeChannel setupRealtimeSubscription({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(String) onDelete,
  }) {
    _channel = _supabase
        .channel('realtime_data_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'realtime_data',
          callback: (payload) {
            final newData = payload.newRecord;
            onInsert(newData);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'realtime_data',
          callback: (payload) {
            final updatedData = payload.newRecord;
            onUpdate(updatedData);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'realtime_data',
          callback: (payload) {
            final deletedKey = payload.oldRecord['key'];
            onDelete(deletedKey);
          },
        )
        .subscribe();

    return _channel!;
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> updateData({
    required String key,
    required String value,
  }) async {
    try {
      // Check if record exists
      final existing = await _supabase
          .from('realtime_data')
          .select()
          .eq('key', key)
          .maybeSingle();

      if (existing != null) {
        // Update existing
        await _supabase
            .from('realtime_data')
            .update({
              'value': value,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('key', key);
      } else {
        // Insert new
        await _supabase.from('realtime_data').insert({
          'key': key,
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (error) {
      throw Exception('Failed to update data: $error');
    }
  }

  Future<void> deleteData(String key) async {
    try {
      await _supabase.from('realtime_data').delete().eq('key', key);
    } catch (error) {
      throw Exception('Failed to delete data: $error');
    }
  }

  Future<int> getCounterValue() async {
    try {
      final data = await fetchRealtimeData();
      final counterData = data['counter'];
      return int.tryParse(counterData?['value']?.toString() ?? '0') ?? 0;
    } catch (error) {
      throw Exception('Failed to get counter value: $error');
    }
  }

  Future<void> incrementCounter() async {
    try {
      final currentValue = await getCounterValue();
      await updateData(key: 'counter', value: (currentValue + 1).toString());
    } catch (error) {
      throw Exception('Failed to increment counter: $error');
    }
  }

  Future<void> decrementCounter() async {
    try {
      final currentValue = await getCounterValue();
      await updateData(key: 'counter', value: (currentValue - 1).toString());
    } catch (error) {
      throw Exception('Failed to decrement counter: $error');
    }
  }

  Future<void> resetCounter() async {
    try {
      await updateData(key: 'counter', value: '0');
    } catch (error) {
      throw Exception('Failed to reset counter: $error');
    }
  }
}