class Message {
  final String? id;
  final String text;
  final DateTime timestamp;

  const Message({
    this.id,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, {String? id}) {
    return Message(
      id: id,
      text: map['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  Message copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.text == text &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ timestamp.hashCode;
}