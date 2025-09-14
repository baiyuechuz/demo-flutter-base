import 'package:flutter/material.dart';
import '../../models/note.dart';
import 'note_item.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final bool isLoading;
  final Function(Note) onEditNote;
  final Function(int) onDeleteNote;
  final VoidCallback onRefresh;

  const NoteList({
    super.key,
    required this.notes,
    required this.isLoading,
    required this.onEditNote,
    required this.onDeleteNote,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.notes, color: Colors.white70),
                  const SizedBox(width: 10),
                  Text(
                    'Your Notes (${notes.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No notes yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add your first note above!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteItem(
          note: note,
          onEdit: () => onEditNote(note),
          onDelete: () => onDeleteNote(note.id!),
        );
      },
    );
  }
}