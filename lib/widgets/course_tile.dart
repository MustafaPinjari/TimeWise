import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseTile extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseTile({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: course.color,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(course.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.instructor != null)
              Text('Instructor: ${course.instructor}'),
            Text('Credit Hours: ${course.creditHours}'),
            const SizedBox(height: 4),
            Text(
              'Time Slots: ${course.availableTimeSlots.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
} 