import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/message.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // References
  late final DatabaseReference _counterRef;
  late final DatabaseReference _messagesRef;
  late final DatabaseReference _connectedRef;

  // Stream subscriptions
  StreamSubscription? _counterSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _connectedSubscription;

  RealtimeDatabaseService() {
    _counterRef = _database.ref('demo/counter');
    _messagesRef = _database.ref('demo/messages');
    _connectedRef = _database.ref('.info/connected');
  }

  // Counter operations
  Stream<int> get counterStream {
    return _counterRef.onValue.map((event) {
      final data = event.snapshot.value;
      return data is int ? data : 0;
    });
  }

  Future<int> getCounter() async {
    try {
      final snapshot = await _counterRef.get();
      final data = snapshot.value;
      return data is int ? data : 0;
    } catch (error) {
      throw Exception('Failed to get counter: $error');
    }
  }

  Future<void> incrementCounter() async {
    try {
      final currentValue = await getCounter();
      await _counterRef.set(currentValue + 1);
    } catch (error) {
      throw Exception('Failed to increment counter: $error');
    }
  }

  Future<void> decrementCounter() async {
    try {
      final currentValue = await getCounter();
      await _counterRef.set(currentValue - 1);
    } catch (error) {
      throw Exception('Failed to decrement counter: $error');
    }
  }

  Future<void> resetCounter() async {
    try {
      await _counterRef.set(0);
    } catch (error) {
      throw Exception('Failed to reset counter: $error');
    }
  }

  Future<void> setCounter(int value) async {
    try {
      await _counterRef.set(value);
    } catch (error) {
      throw Exception('Failed to set counter: $error');
    }
  }

  // Messages operations
  Stream<List<Message>> get messagesStream {
    return _messagesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) {
        return <Message>[];
      }

      final messages = <Message>[];
      data.forEach((key, value) {
        if (value is Map) {
          try {
            final message = Message.fromMap(
              Map<String, dynamic>.from(value),
              id: key.toString(),
            );
            messages.add(message);
          } catch (e) {
            // Skip invalid messages
          }
        }
      });

      // Sort messages by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  Future<List<Message>> getMessages() async {
    try {
      final snapshot = await _messagesRef.get();
      final data = snapshot.value;

      if (data == null || data is! Map) {
        return <Message>[];
      }

      final messages = <Message>[];
      data.forEach((key, value) {
        if (value is Map) {
          try {
            final message = Message.fromMap(
              Map<String, dynamic>.from(value),
              id: key.toString(),
            );
            messages.add(message);
          } catch (e) {
            // Skip invalid messages
          }
        }
      });

      // Sort messages by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    } catch (error) {
      throw Exception('Failed to get messages: $error');
    }
  }

  Future<Message> sendMessage(String text) async {
    try {
      final message = Message(
        text: text.trim(),
        timestamp: DateTime.now(),
      );

      final ref = await _messagesRef.push().set(message.toMap());

      // Return the message with the generated ID
      return message.copyWith(id: _messagesRef.push().key);
    } catch (error) {
      throw Exception('Failed to send message: $error');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesRef.child(messageId).remove();
    } catch (error) {
      throw Exception('Failed to delete message: $error');
    }
  }

  Future<void> clearAllMessages() async {
    try {
      await _messagesRef.remove();
    } catch (error) {
      throw Exception('Failed to clear messages: $error');
    }
  }

  Future<void> updateMessage(String messageId, String newText) async {
    try {
      await _messagesRef.child(messageId).update({
        'text': newText.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (error) {
      throw Exception('Failed to update message: $error');
    }
  }

  // Connection status
  Stream<bool> get connectionStream {
    return _connectedRef.onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }

  Future<bool> isConnected() async {
    try {
      final snapshot = await _connectedRef.get();
      return snapshot.value as bool? ?? false;
    } catch (error) {
      return false;
    }
  }

  // Cleanup method
  void dispose() {
    _counterSubscription?.cancel();
    _messagesSubscription?.cancel();
    _connectedSubscription?.cancel();
  }

  // Batch operations
  Future<void> batchDeleteMessages(List<String> messageIds) async {
    try {
      final Map<String, dynamic> updates = {};
      for (final id in messageIds) {
        updates['$id'] = null; // Setting to null removes the key
      }
      await _messagesRef.update(updates);
    } catch (error) {
      throw Exception('Failed to batch delete messages: $error');
    }
  }

  // Advanced queries
  Future<List<Message>> getMessagesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final messages = await getMessages();
      return messages.where((message) {
        return message.timestamp.isAfter(startDate) &&
               message.timestamp.isBefore(endDate);
      }).toList();
    } catch (error) {
      throw Exception('Failed to get messages in range: $error');
    }
  }

  Future<List<Message>> searchMessages(String query) async {
    try {
      final messages = await getMessages();
      final lowercaseQuery = query.toLowerCase();
      return messages.where((message) {
        return message.text.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (error) {
      throw Exception('Failed to search messages: $error');
    }
  }
}