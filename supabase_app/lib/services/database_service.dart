import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Note.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch notes: $error');
    }
  }

  Future<Note> addNote({
    required String title,
    String? description,
  }) async {
    try {
      final noteData = {
        'title': title.trim(),
        'description': description?.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('notes')
          .insert(noteData)
          .select()
          .single();

      return Note.fromJson(response);
    } catch (error) {
      throw Exception('Failed to add note: $error');
    }
  }

  Future<Note> updateNote({
    required int id,
    required String title,
    String? description,
  }) async {
    try {
      final noteData = {
        'title': title.trim(),
        'description': description?.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('notes')
          .update(noteData)
          .eq('id', id)
          .select()
          .single();

      return Note.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update note: $error');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _supabase.from('notes').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete note: $error');
    }
  }
}