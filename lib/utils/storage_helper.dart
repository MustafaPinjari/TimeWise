import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/timetable_schedule.dart';

class StorageHelper {
  static const String _coursesKey = 'courses';
  static const String _schedulesKey = 'schedules';
  static const String _lastGeneratedKey = 'last_generated';

  static Future<void> saveCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = courses.map((course) => course.toJson()).toList();
    await prefs.setString(_coursesKey, jsonEncode(coursesJson));
  }

  static Future<List<Course>> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString(_coursesKey);
    
    if (coursesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(coursesJson);
    return decoded.map((json) => Course.fromJson(json)).toList();
  }

  static Future<void> saveSchedules(List<TimetableSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = schedules.map((schedule) => schedule.toJson()).toList();
    await prefs.setString(_schedulesKey, jsonEncode(schedulesJson));
  }

  static Future<List<TimetableSchedule>> loadSchedules(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getString(_schedulesKey);
    
    if (schedulesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(schedulesJson);
    return decoded.map((json) => TimetableSchedule.fromJson(json, courses)).toList();
  }

  static Future<void> saveLastGenerated(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastGeneratedKey, dateTime.toIso8601String());
  }

  static Future<DateTime?> loadLastGenerated() async {
    final prefs = await SharedPreferences.getInstance();
    final dateTimeStr = prefs.getString(_lastGeneratedKey);
    
    if (dateTimeStr == null) return null;
    
    return DateTime.parse(dateTimeStr);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coursesKey);
    await prefs.remove(_schedulesKey);
    await prefs.remove(_lastGeneratedKey);
  }
} 