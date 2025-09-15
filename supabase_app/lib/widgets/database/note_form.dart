import 'package:flutter/material.dart';
import '../common/custom_text_field.dart';
import '../../components/custom_button.dart';

class NoteForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey;
  final bool isEditing;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  const NoteForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.formKey,
    required this.isEditing,
    required this.isSubmitting,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Note' : 'Add New Note',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: titleController,
              labelText: 'Title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: descriptionController,
              labelText: 'Description',
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : CustomGradientButton(
                          text: isEditing ? 'Update Note' : 'Add Note',
                          onPressed: onSubmit,
                        ),
                ),
                if (isEditing && onCancel != null) ...[
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}