import 'package:flutter/material.dart';

enum BatchType {
  morning, // 8:00 AM - 3:00 PM
  afternoon // 10:00 AM - 5:00 PM
}

enum SlotType {
  lecture,
  practical,
  library,
  shortBreak,
  lunchBreak,
  vap, // Value Added Program
  training,
  inPlantProject
}

enum CourseType {
  theory,
  practical,
  vap,
  training,
  library
}

class TimeSlot {
  final int day; // 0-5 for Monday-Saturday
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final SlotType type;

  TimeSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'startTime': '${startTime.hour}:${startTime.minute}',
    'endTime': '${endTime.hour}:${endTime.minute}',
    'type': type.toString(),
  };

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    final startTimeParts = json['startTime'].split(':');
    final endTimeParts = json['endTime'].split(':');
    
    return TimeSlot(
      day: json['day'],
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      type: SlotType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SlotType.lecture,
      ),
    );
  }

  bool overlaps(TimeSlot other) {
    if (day != other.day) return false;
    
    final thisStart = startTime.hour * 60 + startTime.minute;
    final thisEnd = endTime.hour * 60 + endTime.minute;
    final otherStart = other.startTime.hour * 60 + other.startTime.minute;
    final otherEnd = other.endTime.hour * 60 + other.endTime.minute;

    return !(thisEnd <= otherStart || thisStart >= otherEnd);
  }
}

class Course {
  final String id;
  final String code; // Course code (e.g., XCA403)
  final String name;
  final String? instructor;
  final int creditHours;
  final Color color;
  final List<TimeSlot> availableTimeSlots;
  final SlotType type;
  final String? classroom; // e.g., "S" Building Classroom No. C3
  final String? division; // e.g., "B"
  final String? batch; // e.g., "B1"
  final String program; // e.g., "BCA"
  final String semester; // e.g., "Sem-VI"
  final CourseType courseType;
  final int rollNumberStart;
  final int rollNumberEnd;
  final int studentCount;
  final String academicYear; // e.g., "2024-25"
  final bool isPractical;

  Course({
    required this.id,
    required this.code,
    required this.name,
    this.instructor,
    required this.creditHours,
    required this.color,
    required this.availableTimeSlots,
    required this.type,
    this.classroom,
    this.division,
    this.batch,
    required this.program,
    required this.semester,
    required this.courseType,
    required this.rollNumberStart,
    required this.rollNumberEnd,
    required this.studentCount,
    required this.academicYear,
    required this.isPractical,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'instructor': instructor,
    'creditHours': creditHours,
    'color': color.value,
    'availableTimeSlots': availableTimeSlots.map((slot) => slot.toJson()).toList(),
    'type': type.toString(),
    'classroom': classroom,
    'division': division,
    'batch': batch,
    'program': program,
    'semester': semester,
    'courseType': courseType.toString(),
    'rollNumberStart': rollNumberStart,
    'rollNumberEnd': rollNumberEnd,
    'studentCount': studentCount,
    'academicYear': academicYear,
    'isPractical': isPractical,
  };

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      instructor: json['instructor'],
      creditHours: json['creditHours'],
      color: Color(json['color']),
      availableTimeSlots: (json['availableTimeSlots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      type: SlotType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SlotType.lecture,
      ),
      classroom: json['classroom'],
      division: json['division'],
      batch: json['batch'],
      program: json['program'],
      semester: json['semester'],
      courseType: CourseType.values.firstWhere(
        (e) => e.toString() == json['courseType'],
        orElse: () => CourseType.theory,
      ),
      rollNumberStart: json['rollNumberStart'],
      rollNumberEnd: json['rollNumberEnd'],
      studentCount: json['studentCount'],
      academicYear: json['academicYear'],
      isPractical: json['isPractical'],
    );
  }

  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? instructor,
    int? creditHours,
    Color? color,
    List<TimeSlot>? availableTimeSlots,
    SlotType? type,
    String? classroom,
    String? division,
    String? batch,
    String? program,
    String? semester,
    CourseType? courseType,
    int? rollNumberStart,
    int? rollNumberEnd,
    int? studentCount,
    String? academicYear,
    bool? isPractical,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      creditHours: creditHours ?? this.creditHours,
      color: color ?? this.color,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      type: type ?? this.type,
      classroom: classroom ?? this.classroom,
      division: division ?? this.division,
      batch: batch ?? this.batch,
      program: program ?? this.program,
      semester: semester ?? this.semester,
      courseType: courseType ?? this.courseType,
      rollNumberStart: rollNumberStart ?? this.rollNumberStart,
      rollNumberEnd: rollNumberEnd ?? this.rollNumberEnd,
      studentCount: studentCount ?? this.studentCount,
      academicYear: academicYear ?? this.academicYear,
      isPractical: isPractical ?? this.isPractical,
    );
  }
} 