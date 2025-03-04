import 'dart:math';
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/timetable_schedule.dart';

class GeneticAlgorithm {
  static const int populationSize = 50;
  static const int generations = 100;
  static const double mutationRate = 0.1;
  static const double crossoverRate = 0.8;

  final List<Course> courses;
  final BatchType batchType;
  final String division;
  final String classroom;
  final String academicYear;
  final String program;
  final String semester;

  GeneticAlgorithm({
    required this.courses,
    required this.batchType,
    required this.division,
    required this.classroom,
    required this.academicYear,
    required this.program,
    required this.semester,
  });

  List<TimetableSchedule> generateSchedules() {
    // Validate input
    if (courses.isEmpty) {
      print('No courses available for generating schedule');
      return [];
    }

    print('Generating schedules for ${courses.length} courses:');
    for (var course in courses) {
      print('Course: ${course.name}, Credit Hours: ${course.creditHours}, Available Slots: ${course.availableTimeSlots.length}');
    }

    List<TimetableSchedule> population = _initializePopulation();
    List<TimetableSchedule> bestSchedules = [];

    print('Initial population size: ${population.length}');

    for (int generation = 0; generation < generations; generation++) {
      // Evaluate fitness
      population.sort((a, b) => b.fitnessScore.compareTo(a.fitnessScore));
      
      if (generation % 10 == 0) {
        print('Generation $generation - Best Fitness: ${population.first.fitnessScore}');
      }
      
      // Keep track of best schedules
      if (bestSchedules.length < 5) {
        bestSchedules.add(population.first);
      } else if (population.first.fitnessScore > bestSchedules.last.fitnessScore) {
        bestSchedules.removeLast();
        bestSchedules.add(population.first);
      }

      // Create new population
      List<TimetableSchedule> newPopulation = [];
      
      // Elitism: Keep best 10% of population
      int eliteSize = (populationSize * 0.1).round();
      newPopulation.addAll(population.take(eliteSize));

      // Generate rest of new population
      while (newPopulation.length < populationSize) {
        if (Random().nextDouble() < crossoverRate) {
          // Crossover
          TimetableSchedule parent1 = _tournamentSelection(population);
          TimetableSchedule parent2 = _tournamentSelection(population);
          TimetableSchedule child = _crossover(parent1, parent2);
          
          // Mutation
          if (Random().nextDouble() < mutationRate) {
            child = _mutate(child);
          }
          
          newPopulation.add(child);
        } else {
          // Clone a good schedule
          newPopulation.add(_tournamentSelection(population));
        }
      }

      population = newPopulation;
    }

    print('Generated ${bestSchedules.length} schedules');
    print('Best fitness score: ${bestSchedules.first.fitnessScore}');

    return bestSchedules;
  }

  List<TimetableSchedule> _initializePopulation() {
    List<TimetableSchedule> population = [];
    final int rows = 7; // 7 time slots for both batches
    final int cols = 6; // Monday to Saturday

    for (int i = 0; i < populationSize; i++) {
      // Create empty grid with time slots
      List<List<TimetableCell>> grid = List.generate(
        rows,
        (row) {
          final startHour = batchType == BatchType.morning ? 8 + row : 10 + row;
          final endHour = startHour + 1;
          final timeSlot = TimeSlot(
            day: 0,
            startTime: TimeOfDay(hour: startHour, minute: 0),
            endTime: TimeOfDay(hour: endHour, minute: 0),
            type: SlotType.lecture,
          );
          return List.generate(
            cols,
            (col) => TimetableCell(timeSlot: _formatTimeSlot(timeSlot)),
          );
        },
      );

      // Add breaks
      _addBreaks(grid);

      // Add courses
      for (Course course in courses) {
        for (TimeSlot slot in course.availableTimeSlots) {
          if (!_isValidTimeSlot(slot)) continue;

          final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
          final batchStartMinutes = batchType == BatchType.morning ? 8 * 60 : 10 * 60;
          final row = ((startMinutes - batchStartMinutes) ~/ 60).clamp(0, rows - 1);

          if (row >= 0 && row < rows && slot.day >= 0 && slot.day < cols) {
            grid[row][slot.day] = TimetableCell(
              course: course,
              timeSlot: _formatTimeSlot(slot),
              isConflict: _checkConflict(grid, row, slot.day, course, slot),
            );
          }
        }
      }

      population.add(TimetableSchedule(
        grid: grid,
        fitnessScore: _calculateFitness(grid),
        courses: courses,
        program: program,
        semester: semester,
        division: division,
        classroom: classroom,
        academicYear: academicYear,
      ));
    }

    return population;
  }

  void _addBreaks(List<List<TimetableCell>> grid) {
    // Short break
    final shortBreakRow = batchType == BatchType.morning ? 2 : 2;
    final shortBreakTime = TimeSlot(
      day: 0,
      startTime: TimeOfDay(hour: batchType == BatchType.morning ? 10 : 12, minute: 0),
      endTime: TimeOfDay(hour: batchType == BatchType.morning ? 10 : 12, minute: 15),
      type: SlotType.shortBreak,
    );

    // Lunch break
    final lunchBreakRow = batchType == BatchType.morning ? 4 : 4;
    final lunchBreakTime = TimeSlot(
      day: 0,
      startTime: TimeOfDay(hour: batchType == BatchType.morning ? 12 : 14, minute: 0),
      endTime: TimeOfDay(hour: batchType == BatchType.morning ? 12 : 14, minute: 45),
      type: SlotType.lunchBreak,
    );

    // Add breaks to all days
    for (int col = 0; col < grid[0].length; col++) {
      grid[shortBreakRow][col] = TimetableCell(
        isBreak: true,
        breakType: 'Short Break',
        timeSlot: _formatTimeSlot(shortBreakTime),
      );

      grid[lunchBreakRow][col] = TimetableCell(
        isBreak: true,
        breakType: 'Lunch Break',
        timeSlot: _formatTimeSlot(lunchBreakTime),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _isValidTimeSlot(TimeSlot slot) {
    // Convert times to minutes for easier comparison
    final startMinutes = slot.startTime.hour * 60 + slot.startTime.minute;
    final endMinutes = slot.endTime.hour * 60 + slot.endTime.minute;

    // Define batch time ranges
    final batchStartMinutes = batchType == BatchType.morning ? 8 * 60 : 10 * 60;
    final batchEndMinutes = batchType == BatchType.morning ? 15 * 60 : 17 * 60;

    // Check if slot is within batch time range
    if (startMinutes < batchStartMinutes || endMinutes > batchEndMinutes) {
      return false;
    }

    // Define break times
    final shortBreakStart = batchType == BatchType.morning ? 10 * 60 : 12 * 60;
    final shortBreakEnd = shortBreakStart + 15;
    final lunchBreakStart = batchType == BatchType.morning ? 12 * 60 : 14 * 60;
    final lunchBreakEnd = lunchBreakStart + 45;

    // Check if slot overlaps with breaks
    if ((startMinutes < shortBreakEnd && endMinutes > shortBreakStart) ||
        (startMinutes < lunchBreakEnd && endMinutes > lunchBreakStart)) {
      return false;
    }

    return true;
  }

  String _formatTimeSlot(TimeSlot slot) {
    return '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}';
  }

  bool _isBreakTimeSlot(String timeSlotStr) {
    // Parse the time slot string
    final parts = timeSlotStr.split(' - ');
    if (parts.length != 2) return false;

    int _parseHour(String timeStr) {
      // Split into time and period (AM/PM)
      final timeParts = timeStr.trim().split(' ');
      if (timeParts.length != 2) return 0;

      // Split hours and minutes
      final timeComponents = timeParts[0].split(':');
      if (timeComponents.length != 2) return 0;

      try {
        int hour = int.parse(timeComponents[0]);
        final period = timeParts[1].toUpperCase();
        
        // Convert to 24-hour format
        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }
        
        return hour;
      } catch (e) {
        return 0; // Return 0 for any parsing errors
      }
    }

    final startHour = _parseHour(parts[0]);
    final endHour = _parseHour(parts[1]);

    // Short break times (10:00 AM - 10:15 AM)
    if (startHour == 10 && endHour == 10) return true;

    // Lunch break time (12:00 PM - 1:00 PM)
    if (startHour == 12 && endHour == 13) return true;

    return false;
  }

  TimetableSchedule _crossover(TimetableSchedule parent1, TimetableSchedule parent2) {
    List<List<TimetableCell>> childGrid = List.generate(
      parent1.grid.length,
      (row) => List.generate(
        parent1.grid[0].length,
        (col) => TimetableCell(timeSlot: parent1.grid[row][col].timeSlot),
      ),
    );

    // Add breaks first
    _addBreaks(childGrid);

    // Uniform crossover for course cells
    for (int i = 0; i < parent1.grid.length; i++) {
      for (int j = 0; j < parent1.grid[0].length; j++) {
        if (!childGrid[i][j].isBreak) {
          childGrid[i][j] = Random().nextBool()
              ? parent1.grid[i][j]
              : parent2.grid[i][j];
        }
      }
    }

    return TimetableSchedule(
      grid: childGrid,
      fitnessScore: _calculateFitness(childGrid),
      courses: courses,
      program: program,
      semester: semester,
      division: division,
      classroom: classroom,
      academicYear: academicYear,
    );
  }

  TimetableSchedule _mutate(TimetableSchedule schedule) {
    List<List<TimetableCell>> mutatedGrid = List.generate(
      schedule.grid.length,
      (i) => List.generate(schedule.grid[0].length, (j) => schedule.grid[i][j]),
    );

    // Randomly select a cell and try to assign a random course
    int maxAttempts = 10;
    while (maxAttempts > 0) {
      int row = Random().nextInt(mutatedGrid.length);
      int col = Random().nextInt(mutatedGrid[0].length);
      
      // Skip if it's a break cell
      if (mutatedGrid[row][col].isBreak) {
        maxAttempts--;
        continue;
      }

      Course randomCourse = courses[Random().nextInt(courses.length)];
      List<TimeSlot> availableSlots = randomCourse.availableTimeSlots
          .where((slot) => _isValidTimeSlot(slot))
          .toList();
      
      if (availableSlots.isNotEmpty) {
        TimeSlot randomSlot = availableSlots[Random().nextInt(availableSlots.length)];
        mutatedGrid[row][col] = TimetableCell(
          course: randomCourse,
          timeSlot: _formatTimeSlot(randomSlot),
          isConflict: _checkConflict(mutatedGrid, row, col, randomCourse, randomSlot),
        );
        break;
      }
      
      maxAttempts--;
    }

    return TimetableSchedule(
      grid: mutatedGrid,
      fitnessScore: _calculateFitness(mutatedGrid),
      courses: courses,
      program: program,
      semester: semester,
      division: division,
      classroom: classroom,
      academicYear: academicYear,
    );
  }

  double _calculateFitness(List<List<TimetableCell>> grid) {
    double fitness = 1.0;
    int totalConflicts = 0;
    Map<Course, int> courseCounts = {};
    Map<Course, Set<int>> courseDays = {};

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[0].length; col++) {
        final cell = grid[row][col];
        
        // Skip break cells
        if (cell.isBreak) continue;

        if (cell.course != null) {
          // Count course occurrences
          courseCounts[cell.course!] = (courseCounts[cell.course!] ?? 0) + 1;
          
          // Track unique days for each course
          courseDays.putIfAbsent(cell.course!, () => {}).add(col);

          // Check for conflicts
          if (cell.isConflict) {
            totalConflicts++;
          }
        }
      }
    }

    // Penalize for conflicts
    fitness -= (totalConflicts * 0.1);

    // Penalize for uneven distribution of courses
    for (var course in courses) {
      final count = courseCounts[course] ?? 0;
      final expectedCount = course.creditHours;
      final diff = (count - expectedCount).abs();
      fitness -= (diff * 0.05);

      // Penalize for courses not spread across days
      final uniqueDays = courseDays[course]?.length ?? 0;
      if (uniqueDays < expectedCount) {
        fitness -= ((expectedCount - uniqueDays) * 0.02);
      }
    }

    // Ensure fitness is between 0 and 1
    return fitness.clamp(0.0, 1.0);
  }

  bool _checkConflict(
    List<List<TimetableCell>> grid,
    int row,
    int col,
    Course course,
    TimeSlot timeSlot,
  ) {
    // Check if the cell is a break
    if (grid[row][col].isBreak) {
      return true;
    }

    // Check for conflicts in the same time slot
    if (grid[row][col].course != null && grid[row][col].course != course) {
      return true;
    }

    // Convert time to minutes for easier comparison
    final slotStartMinutes = timeSlot.startTime.hour * 60 + timeSlot.startTime.minute;
    final slotEndMinutes = timeSlot.endTime.hour * 60 + timeSlot.endTime.minute;

    // Check for conflicts in adjacent time slots (same day)
    for (int i = 0; i < grid.length; i++) {
      if (i == row) continue; // Skip current row

      final cell = grid[i][col];
      if (cell.course == null || cell.course == course) continue;

      // Parse the time slot string to get start and end times
      final parts = cell.timeSlot.split(' - ');
      if (parts.length != 2) continue;

      final startParts = parts[0].trim().split(' ');
      final endParts = parts[1].trim().split(' ');
      if (startParts.length != 2 || endParts.length != 2) continue;

      final startTimeParts = startParts[0].split(':');
      final endTimeParts = endParts[0].split(':');
      if (startTimeParts.length != 2 || endTimeParts.length != 2) continue;

      try {
        int startHour = int.parse(startTimeParts[0]);
        int endHour = int.parse(endTimeParts[0]);

        // Convert to 24-hour format
        if (startParts[1] == 'PM' && startHour != 12) startHour += 12;
        if (endParts[1] == 'PM' && endHour != 12) endHour += 12;
        if (startParts[1] == 'AM' && startHour == 12) startHour = 0;
        if (endParts[1] == 'AM' && endHour == 12) endHour = 0;

        final cellStartMinutes = startHour * 60 + int.parse(startTimeParts[1]);
        final cellEndMinutes = endHour * 60 + int.parse(endTimeParts[1]);

        // Check for overlap
        if (slotStartMinutes < cellEndMinutes && slotEndMinutes > cellStartMinutes) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  int _timeToRow(TimeOfDay time) {
    final timeInMinutes = time.hour * 60 + time.minute;
    final startTime = batchType == BatchType.morning ? 8 * 60 : 10 * 60;
    return ((timeInMinutes - startTime) ~/ 60).clamp(0, 6); // 7 time slots (0-6)
  }

  TimetableSchedule _tournamentSelection(List<TimetableSchedule> population) {
    const tournamentSize = 3;
    List<TimetableSchedule> tournament = [];
    
    for (int i = 0; i < tournamentSize; i++) {
      tournament.add(population[Random().nextInt(population.length)]);
    }
    
    tournament.sort((a, b) => b.fitnessScore.compareTo(a.fitnessScore));
    return tournament.first;
  }
} 