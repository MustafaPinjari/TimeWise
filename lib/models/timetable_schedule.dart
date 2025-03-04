import 'course.dart';

class TimetableCell {
  final Course? course;
  final TimeSlot? timeSlot;
  final bool isConflict;

  TimetableCell({
    this.course,
    this.timeSlot,
    this.isConflict = false,
  });
}

class TimetableSchedule {
  final List<List<TimetableCell>> grid;
  final double fitnessScore;
  final List<Course> courses;
  final DateTime generatedAt;

  TimetableSchedule({
    required this.grid,
    required this.fitnessScore,
    required this.courses,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'grid': grid.map((row) => 
      row.map((cell) => {
        'courseId': cell.course?.id,
        'timeSlot': cell.timeSlot?.toJson(),
        'isConflict': cell.isConflict,
      }).toList()
    ).toList(),
    'fitnessScore': fitnessScore,
    'courseIds': courses.map((course) => course.id).toList(),
    'generatedAt': generatedAt.toIso8601String(),
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
          timeSlot: cell['timeSlot'] != null ? TimeSlot.fromJson(cell['timeSlot']) : null,
          isConflict: cell['isConflict'] ?? false,
        )).toList()
      ).toList(),
      fitnessScore: json['fitnessScore'],
      courses: (json['courseIds'] as List)
          .map((id) => allCourses.firstWhere((course) => course.id == id))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  int get totalConflicts {
    return grid.expand((row) => row)
        .where((cell) => cell.isConflict)
        .length;
  }

  bool hasTimeSlot(Course course, TimeSlot timeSlot) {
    return grid.expand((row) => row).any((cell) =>
        cell.course?.id == course.id && cell.timeSlot == timeSlot);
  }

  List<TimeSlot> getAvailableTimeSlotsForCourse(Course course) {
    return course.availableTimeSlots.where((slot) => !hasTimeSlot(course, slot)).toList();
  }
} 