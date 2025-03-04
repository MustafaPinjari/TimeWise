import 'package:flutter/material.dart';

class TimeSlot {
  final int day; // 0-4 for Monday-Friday
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'startTime': '${startTime.hour}:${startTime.minute}',
    'endTime': '${endTime.hour}:${endTime.minute}',
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
    );
  }
}

class Course {
  final String id;
  final String name;
  final String? instructor;
  final int creditHours;
  final Color color;
  final List<TimeSlot> availableTimeSlots;

  Course({
    required this.id,
    required this.name,
    this.instructor,
    required this.creditHours,
    required this.color,
    required this.availableTimeSlots,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'instructor': instructor,
    'creditHours': creditHours,
    'color': color.value,
    'availableTimeSlots': availableTimeSlots.map((slot) => slot.toJson()).toList(),
  };

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      instructor: json['instructor'],
      creditHours: json['creditHours'],
      color: Color(json['color']),
      availableTimeSlots: (json['availableTimeSlots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? instructor,
    int? creditHours,
    Color? color,
    List<TimeSlot>? availableTimeSlots,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      creditHours: creditHours ?? this.creditHours,
      color: color ?? this.color,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
    );
  }
} 