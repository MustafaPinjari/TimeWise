import 'package:flutter/material.dart';
import 'course.dart';

class TimetableCell {
  final Course? course;
  final bool isConflict;
  final bool isBreak;
  final String breakType;
  final String timeSlot;

  TimetableCell({
    this.course,
    this.isConflict = false,
    this.isBreak = false,
    this.breakType = '',
    required this.timeSlot,
  });

  TimetableCell copyWith({
    Course? course,
    bool? isConflict,
    bool? isBreak,
    String? breakType,
    String? timeSlot,
  }) {
    return TimetableCell(
      course: course ?? this.course,
      isConflict: isConflict ?? this.isConflict,
      isBreak: isBreak ?? this.isBreak,
      breakType: breakType ?? this.breakType,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }

  bool get isShortBreak => isBreak && breakType == "Short Break";
  bool get isLunchBreak => isBreak && breakType == "Lunch Break";
}

class TimetableSchedule {
  final List<List<TimetableCell>> grid;
  final double fitnessScore;
  final List<Course> courses;
  final String program;
  final String semester;
  final String division;
  final String classroom;
  final String academicYear;

  TimetableSchedule({
    required this.grid,
    required this.fitnessScore,
    required this.courses,
    required this.program,
    required this.semester,
    required this.division,
    required this.classroom,
    required this.academicYear,
  });

  factory TimetableSchedule.empty() {
    final List<String> timeSlots = [
      '8:00 AM - 9:00 AM',
      '9:00 AM - 10:00 AM',
      '10:00 AM - 11:00 AM',
      '11:00 AM - 12:00 PM',
      '12:00 PM - 1:00 PM',
      '1:00 PM - 2:00 PM',
      '2:00 PM - 3:00 PM',
    ];

    return TimetableSchedule(
      grid: List.generate(
        7,
        (row) => List.generate(
          6,
          (col) => TimetableCell(timeSlot: timeSlots[row]),
        ),
      ),
      fitnessScore: 0.0,
      courses: [],
      program: '',
      semester: '',
      division: '',
      classroom: '',
      academicYear: '',
    );
  }

  TimetableSchedule copyWith({
    List<List<TimetableCell>>? grid,
    double? fitnessScore,
    List<Course>? courses,
    String? program,
    String? semester,
    String? division,
    String? classroom,
    String? academicYear,
  }) {
    return TimetableSchedule(
      grid: grid ?? this.grid,
      fitnessScore: fitnessScore ?? this.fitnessScore,
      courses: courses ?? this.courses,
      program: program ?? this.program,
      semester: semester ?? this.semester,
      division: division ?? this.division,
      classroom: classroom ?? this.classroom,
      academicYear: academicYear ?? this.academicYear,
    );
  }

  Map<String, dynamic> toJson() => {
    'grid': grid.map((row) => 
      row.map((cell) => {
        'courseId': cell.course?.id,
        'timeSlot': cell.timeSlot,
        'isConflict': cell.isConflict,
        'isBreak': cell.isBreak,
        'breakType': cell.breakType,
      }).toList()
    ).toList(),
    'fitnessScore': fitnessScore,
    'courseIds': courses.map((course) => course.id).toList(),
    'program': program,
    'semester': semester,
    'division': division,
    'classroom': classroom,
    'academicYear': academicYear,
  };

  factory TimetableSchedule.fromJson(Map<String, dynamic> json, List<Course> allCourses) {
    return TimetableSchedule(
      grid: (json['grid'] as List).map((row) => 
        (row as List).map((cell) => TimetableCell(
          course: cell['courseId'] != null 
              ? allCourses.firstWhere(
                  (course) => course.id == cell['courseId'],
                  orElse: () => allCourses.first,
                )
              : null,
          isConflict: cell['isConflict'] ?? false,
          isBreak: cell['isBreak'] ?? false,
          breakType: cell['breakType'] ?? '',
          timeSlot: cell['timeSlot'] ?? '',
        )).toList()
      ).toList(),
      fitnessScore: json['fitnessScore'],
      courses: (json['courseIds'] as List)
          .map((id) => allCourses.firstWhere((course) => course.id == id))
          .toList(),
      program: json['program'],
      semester: json['semester'],
      division: json['division'],
      classroom: json['classroom'],
      academicYear: json['academicYear'],
    );
  }

  int get totalConflicts {
    return grid.expand((row) => row)
        .where((cell) => cell.isConflict)
        .length;
  }

  bool hasTimeSlot(Course course, TimeSlot timeSlot) {
    return grid.expand((row) => row).any((cell) =>
        cell.course?.id == course.id && _timeSlotToString(timeSlot) == cell.timeSlot);
  }

  List<TimeSlot> getAvailableTimeSlotsForCourse(Course course) {
    return course.availableTimeSlots.where((slot) => !hasTimeSlot(course, slot)).toList();
  }

  // Get the row index for a given time
  int getRowForTime(TimeOfDay time) {
    final timeInMinutes = time.hour * 60 + time.minute;
    final startTime = 8 * 60; // Assuming morning batch starts at 8:00 AM
    return ((timeInMinutes - startTime) ~/ 60).clamp(0, grid.length - 1);
  }

  String _timeSlotToString(TimeSlot slot) {
    String _formatTime(TimeOfDay time) {
      final hour = time.hour;
      final period = hour >= 12 ? 'PM' : 'AM';
      final adjustedHour = hour > 12 ? hour - 12 : hour;
      return '${adjustedHour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
    return '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}';
  }

  // Check if a time slot is during break time
  bool isBreakTime(String timeSlotStr) {
    // Parse the time slot string
    final parts = timeSlotStr.split(' - ');
    if (parts.length != 2) return false;

    final startParts = parts[0].split(':');
    final endParts = parts[1].split(':');
    
    if (startParts.length != 2 || endParts.length != 2) return false;

    int _parseHour(String timeStr) {
      final timeParts = timeStr.split(' ');
      int hour = int.parse(timeParts[0]);
      if (timeParts[1] == 'PM' && hour != 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;
      return hour;
    }

    final startHour = _parseHour(parts[0]);
    final endHour = _parseHour(parts[1]);
    
    final startMinutes = startHour * 60;
    final endMinutes = endHour * 60;

    // Short break times (10:00 AM - 10:15 AM)
    if (startHour == 10 && endHour == 10) return true;

    // Lunch break time (12:00 PM - 1:00 PM)
    if (startHour == 12 && endHour == 13) return true;

    return false;
  }
} 