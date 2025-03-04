import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/pdf_export.dart';
import '../models/course.dart';
import '../models/timetable_schedule.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

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
          TextButton.icon(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text(
              'Export PDF',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _isExporting ? null : _exportToPdf,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isExporting ? null : _exportToPdf,
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
        label: const Text('Export as PDF'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.schedules.isEmpty) {
            return const Center(
              child: Text('No timetables generated yet.'),
            );
          }

          final schedule = provider.schedules[_currentIndex];

          return SingleChildScrollView(
            child: Column(
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
                // Timetable Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'School of Computer Sciences & Engineering',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Department of Computer Science and Application',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ACADEMIC YEAR: ${schedule.academicYear}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Program: ${schedule.program}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Semester: ${schedule.semester}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Division: ${schedule.division}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Class Room: "${schedule.classroom}"',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Timetable Grid
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            _buildHeaderCell('Time', isTime: true),
                            for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'])
                              _buildHeaderCell(day),
                          ],
                        ),
                        // Time Slots
                        for (var timeSlot in _getTimeSlots())
                          Row(
                            children: [
                              _buildHeaderCell(timeSlot, isTime: true),
                              for (int col = 0; col < 6; col++)
                                _buildCourseCell(schedule.grid[_getTimeSlotIndex(timeSlot)][col]),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Course Legend
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theory/Tutorial Course',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Course Code'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Course Name'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Full Name'),
                              ),
                            ],
                          ),
                          ...provider.courses
                              .where((course) => !course.isPractical)
                              .map((course) => TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(course.code),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(course.name),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(course.instructor ?? ''),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Practical Course',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Course Code'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Course Name'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Full Name'),
                              ),
                            ],
                          ),
                          ...provider.courses
                              .where((course) => course.isPractical)
                              .map((course) => TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(course.code),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(course.name),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(course.instructor ?? ''),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getTimeSlots() {
    final batchType = context.read<CourseProvider>().schedules[_currentIndex].grid[0][0].timeSlot.startsWith('8:00') 
      ? BatchType.morning 
      : BatchType.afternoon;

    final List<TimeSlot> slots = List.generate(7, (row) {
      final startHour = batchType == BatchType.morning ? 8 + row : 10 + row;
      final endHour = startHour + 1;
      return TimeSlot(
        day: 0,
        startTime: TimeOfDay(hour: startHour, minute: 0),
        endTime: TimeOfDay(hour: endHour, minute: 0),
        type: SlotType.lecture,
      );
    });

    return slots.map((slot) {
      final startHour = slot.startTime.hour == 0 ? 12 : slot.startTime.hour > 12 ? slot.startTime.hour - 12 : slot.startTime.hour;
      final endHour = slot.endTime.hour == 0 ? 12 : slot.endTime.hour > 12 ? slot.endTime.hour - 12 : slot.endTime.hour;
      final startPeriod = slot.startTime.hour < 12 ? 'AM' : 'PM';
      final endPeriod = slot.endTime.hour < 12 ? 'AM' : 'PM';
      return '${startHour}:00 $startPeriod - ${endHour}:00 $endPeriod';
    }).toList();
  }

  int _getTimeSlotIndex(String timeSlot) {
    return _getTimeSlots().indexOf(timeSlot);
  }

  Widget _buildHeaderCell(String text, {bool isTime = false}) {
    return Container(
      width: isTime ? 150 : 200,
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCourseCell(TimetableCell cell) {
    // Get the time slot index safely
    final timeSlotIndex = _getTimeSlots().indexWhere((slot) {
      // Convert both time slots to 24-hour format for comparison
      final cellParts = cell.timeSlot.split(' - ');
      final slotParts = slot.split(' - ');
      
      if (cellParts.length != 2 || slotParts.length != 2) return false;
      
      final cellStart = _parseTimeString(cellParts[0]);
      final slotStart = _parseTimeString(slotParts[0]);
      
      return cellStart == slotStart;
    });

    if (timeSlotIndex == -1) {
      // If time slot is not found, return an empty cell
      return Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
      );
    }

    // Special handling for break times
    final timeSlot = _getTimeSlots()[timeSlotIndex];
    if (timeSlot == '10:00 AM - 11:00 AM') {
      return Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Center(
          child: Text(
            'SHORT BREAK\n(10:00 AM - 10:15 AM)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (timeSlot == '12:00 PM - 1:00 PM') {
      return Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Center(
          child: Text(
            'LUNCH BREAK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    if (cell.isBreak) {
      return Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            cell.breakType == 'Lunch Break' ? 'LUNCH BREAK' : 'SHORT BREAK',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    if (cell.course == null) {
      return Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Center(
          child: Text(
            'LIBRARY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        color: cell.course!.color.withOpacity(0.2),
        border: Border.all(
          color: cell.isConflict ? Colors.red : cell.course!.color,
          width: cell.isConflict ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            cell.course!.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cell.course!.color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (cell.course!.instructor != null)
            Text(
              cell.course!.instructor!,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  String _parseTimeString(String timeStr) {
    final parts = timeStr.trim().split(' ');
    if (parts.length != 2) return '';

    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return '';

    int hour = int.parse(timeParts[0]);
    final period = parts[1].toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:${timeParts[1]}';
  }

  Future<void> _exportToPdf() async {
    setState(() => _isExporting = true);
    try {
      final schedule = context.read<CourseProvider>().schedules[_currentIndex];
      final bytes = await PdfExport.exportTimetable(schedule);

      if (bytes.isEmpty) {
        throw Exception('Generated PDF is empty');
      }

      if (kIsWeb) {
        // Web platform: Download using HTML
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'timetable_${schedule.program}_${schedule.semester}.pdf';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timetable exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String? filePath;
        if (Platform.isWindows) {
          // Save to Downloads folder on Windows
          final String downloadPath = '${Platform.environment['USERPROFILE']}\\Downloads';
          final fileName = 'timetable_${schedule.program}_${schedule.semester}.pdf';
          filePath = '$downloadPath\\$fileName';
        } else {
          // Other platforms: Save to app documents directory
          final directory = await getApplicationDocumentsDirectory();
          final fileName = 'timetable_${schedule.program}_${schedule.semester}.pdf';
          filePath = '${directory.path}/$fileName';
        }

        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        if (Platform.isAndroid) {
          // Use platform channel to open PDF on Android
          const platform = MethodChannel('com.example.timewise/pdf');
          try {
            await platform.invokeMethod('openPdf', {'filePath': filePath});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Timetable exported and opened successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Timetable saved to $filePath'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Desktop and iOS platforms
          try {
            if (Platform.isWindows) {
              await Process.run('explorer', [filePath], runInShell: true);
            } else if (Platform.isMacOS) {
              await Process.run('open', [filePath]);
            } else if (Platform.isLinux) {
              await Process.run('xdg-open', [filePath]);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Timetable saved to $filePath'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Timetable saved to $filePath'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint('PDF Export Error: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }
} 