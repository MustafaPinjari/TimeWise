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
  final int rows;
  final int columns;

  GeneticAlgorithm({
    required this.courses,
    required this.rows,
    required this.columns,
  });

  List<TimetableSchedule> generateSchedules() {
    List<TimetableSchedule> population = _initializePopulation();
    List<TimetableSchedule> bestSchedules = [];

    for (int generation = 0; generation < generations; generation++) {
      // Evaluate fitness
      population.sort((a, b) => b.fitnessScore.compareTo(a.fitnessScore));
      
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

    return bestSchedules;
  }

  List<TimetableSchedule> _initializePopulation() {
    List<TimetableSchedule> population = [];
    
    for (int i = 0; i < populationSize; i++) {
      List<List<TimetableCell>> grid = List.generate(
        rows,
        (i) => List.generate(columns, (j) => TimetableCell()),
      );

      // Assign all time slots for each course
      for (Course course in courses) {
        for (TimeSlot slot in course.availableTimeSlots) {
          int row = _timeToRow(slot.startTime);
          int col = slot.day;
          
          if (row >= 0 && row < rows && col >= 0 && col < columns) {
            grid[row][col] = TimetableCell(
              course: course,
              timeSlot: slot,
              isConflict: _checkConflict(grid, row, col, course, slot),
            );
          }
        }
      }

      population.add(TimetableSchedule(
        grid: grid,
        fitnessScore: _calculateFitness(grid),
        courses: courses,
      ));
    }

    return population;
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

  TimetableSchedule _crossover(TimetableSchedule parent1, TimetableSchedule parent2) {
    List<List<TimetableCell>> childGrid = List.generate(
      rows,
      (i) => List.generate(columns, (j) => TimetableCell()),
    );

    // Uniform crossover
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        childGrid[i][j] = Random().nextBool()
            ? parent1.grid[i][j]
            : parent2.grid[i][j];
      }
    }

    return TimetableSchedule(
      grid: childGrid,
      fitnessScore: _calculateFitness(childGrid),
      courses: courses,
    );
  }

  TimetableSchedule _mutate(TimetableSchedule schedule) {
    List<List<TimetableCell>> mutatedGrid = List.generate(
      rows,
      (i) => List.generate(columns, (j) => schedule.grid[i][j]),
    );

    // Randomly select a cell and try to assign a random course
    int row = Random().nextInt(rows);
    int col = Random().nextInt(columns);
    
    Course randomCourse = courses[Random().nextInt(courses.length)];
    List<TimeSlot> availableSlots = randomCourse.availableTimeSlots;
    
    if (availableSlots.isNotEmpty) {
      TimeSlot randomSlot = availableSlots[Random().nextInt(availableSlots.length)];
      mutatedGrid[row][col] = TimetableCell(
        course: randomCourse,
        timeSlot: randomSlot,
        isConflict: _checkConflict(mutatedGrid, row, col, randomCourse, randomSlot),
      );
    }

    return TimetableSchedule(
      grid: mutatedGrid,
      fitnessScore: _calculateFitness(mutatedGrid),
      courses: courses,
    );
  }

  double _calculateFitness(List<List<TimetableCell>> grid) {
    double fitness = 1.0;
    
    // Penalize conflicts
    int conflicts = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (grid[i][j].isConflict) {
          conflicts++;
        }
      }
    }
    fitness -= (conflicts / (rows * columns)) * 0.5;

    // Reward course distribution
    Map<Course, int> courseCounts = {};
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        Course? course = grid[i][j].course;
        if (course != null) {
          courseCounts[course] = (courseCounts[course] ?? 0) + 1;
        }
      }
    }

    // Penalize uneven distribution
    double expectedCount = (rows * columns) / courses.length;
    for (int count in courseCounts.values) {
      fitness -= (count - expectedCount).abs() / (rows * columns) * 0.3;
    }

    return fitness;
  }

  bool _checkConflict(
    List<List<TimetableCell>> grid,
    int row,
    int col,
    Course course,
    TimeSlot timeSlot,
  ) {
    // Check for conflicts in the same time slot
    if (grid[row][col].course != null && grid[row][col].course != course) {
      return true;
    }

    // Check for conflicts in adjacent time slots
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        
        int newRow = row + i;
        int newCol = col + j;
        
        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
          if (grid[newRow][newCol].course != null &&
              grid[newRow][newCol].course != course) {
            return true;
          }
        }
      }
    }

    return false;
  }

  int _timeToRow(TimeOfDay time) {
    return time.hour - 8; // Convert time to row index (8:00 = row 0)
  }
} 