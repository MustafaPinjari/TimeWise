import 'package:flutter/material.dart';
import '../models/timetable_schedule.dart';

class TimetableView extends StatelessWidget {
  final TimetableSchedule schedule;
  final int currentIndex;
  final int totalSchedules;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const TimetableView({
    super.key,
    required this.schedule,
    required this.currentIndex,
    required this.totalSchedules,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Navigation and Info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentIndex > 0 ? onPrevious : null,
              ),
              Text(
                'Schedule ${currentIndex + 1} of $totalSchedules',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentIndex < totalSchedules - 1 ? onNext : null,
              ),
            ],
          ),
        ),
        // Fitness Score
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Fitness Score: ${(schedule.fitnessScore * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Timetable Grid
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Time'),
                          ),
                        ),
                        for (int i = 0; i < 5; i++)
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text([
                                'Monday',
                                'Tuesday',
                                'Wednesday',
                                'Thursday',
                                'Friday'
                              ][i]),
                            ),
                          ),
                      ],
                    ),
                    // Time Slots
                    for (int row = 0; row < 12; row++)
                      TableRow(
                        children: [
                          // Time Column
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${row + 8}:00'),
                            ),
                          ),
                          // Course Cells
                          for (int col = 0; col < 5; col++)
                            TableCell(
                              child: _buildCourseCell(context, schedule.grid[row][col]),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCell(BuildContext context, TimetableCell cell) {
    if (cell.course == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: cell.course!.color.withOpacity(0.2),
        border: Border.all(
          color: cell.isConflict ? Colors.red : cell.course!.color,
          width: cell.isConflict ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cell.course!.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cell.course!.color,
            ),
          ),
          if (cell.course!.instructor != null)
            Text(
              cell.course!.instructor!,
              style: const TextStyle(fontSize: 12),
            ),
          Text(
            '${cell.timeSlot!.startTime.format(context)} - ${cell.timeSlot!.endTime.format(context)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
} 