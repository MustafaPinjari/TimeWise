import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/pdf_export.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  int _currentIndex = 0;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Timetables'),
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isExporting ? null : _exportToPdf,
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.schedules.isEmpty) {
            return const Center(
              child: Text('No timetables generated yet.'),
            );
          }

          final schedule = provider.schedules[_currentIndex];

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
                      onPressed: _currentIndex > 0
                          ? () => setState(() => _currentIndex--)
                          : null,
                    ),
                    Column(
                      children: [
                        Text(
                          'Schedule ${_currentIndex + 1} of ${provider.schedules.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Fitness: ${(schedule.fitnessScore * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentIndex < provider.schedules.length - 1
                          ? () => setState(() => _currentIndex++)
                          : null,
                    ),
                  ],
                ),
              ),
              // Export Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportToPdf,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isExporting ? 'Exporting...' : 'Export to PDF'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              _buildHeaderCell('Time', isTime: true),
                              for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                                _buildHeaderCell(day),
                            ],
                          ),
                          // Time Slots
                          for (int row = 0; row < 12; row++)
                            Row(
                              children: [
                                // Time Column
                                _buildHeaderCell('${row + 8}:00', isTime: true),
                                // Course Cells
                                for (int col = 0; col < 5; col++)
                                  _buildCourseCell(schedule.grid[row][col]),
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
        },
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool isTime = false}) {
    return Container(
      width: isTime ? 80 : 200,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildCourseCell(cell) {
    if (cell.course == null) {
      return Container(
        width: 200,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
      );
    }

    return Container(
      width: 200,
      height: 80,
      decoration: BoxDecoration(
        color: cell.course.color.withOpacity(0.2),
        border: Border.all(
          color: cell.isConflict ? Colors.red : cell.course.color,
          width: cell.isConflict ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cell.course.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cell.course.color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (cell.course.instructor != null)
            Text(
              cell.course.instructor!,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          if (cell.timeSlot != null)
            Text(
              '${cell.timeSlot.startTime.format(context)} - ${cell.timeSlot.endTime.format(context)}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    final provider = context.read<CourseProvider>();
    if (provider.schedules.isEmpty) return;

    setState(() => _isExporting = true);

    try {
      final schedule = provider.schedules[_currentIndex];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'timetable_$timestamp.pdf';

      // Generate PDF bytes
      final List<int> pdfBytes = await PdfExport.exportTimetable(schedule);

      // Create Blob
      final blob = html.Blob([Uint8List.fromList(pdfBytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create download link
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);

      // Trigger download
      anchor.click();

      // Cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timetable downloaded successfully'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting timetable: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
} 