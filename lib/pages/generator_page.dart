import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../utils/genetic_algorithm.dart';
import '../widgets/course_input.dart';
import '../widgets/course_tile.dart';
import '../models/course.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  bool _isGenerating = false;
  BatchType _selectedBatch = BatchType.morning;
  String _selectedDivision = 'B';
  String _selectedProgram = 'BCA';
  String _selectedSemester = 'Sem-VI';
  String _selectedClassroom = 'S-C3';
  String _selectedAcademicYear = '2024-25';

  @override
  void initState() {
    super.initState();
    context.read<CourseProvider>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Courses'),
                  content: const Text('Are you sure you want to remove all courses?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CourseProvider>().clearAll();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Batch Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Timetable Settings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<BatchType>(
                          value: _selectedBatch,
                          decoration: const InputDecoration(
                            labelText: 'Batch',
                          ),
                          items: BatchType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type == BatchType.morning ? 'B1 (8:00 AM - 3:00 PM)' : 'B2 (10:00 AM - 5:00 PM)'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBatch = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _selectedDivision,
                          decoration: const InputDecoration(
                            labelText: 'Division',
                            hintText: 'e.g., B',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedDivision = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _selectedClassroom,
                          decoration: const InputDecoration(
                            labelText: 'Classroom',
                            hintText: 'e.g., S-C3',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedClassroom = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedProgram,
                          decoration: const InputDecoration(
                            labelText: 'Program',
                          ),
                          items: ['BCA', 'MCA', 'B.Tech', 'M.Tech'].map((program) {
                            return DropdownMenuItem(
                              value: program,
                              child: Text(program),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProgram = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedSemester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                          ),
                          items: ['Sem-I', 'Sem-II', 'Sem-III', 'Sem-IV', 'Sem-V', 'Sem-VI'].map((sem) {
                            return DropdownMenuItem(
                              value: sem,
                              child: Text(sem),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSemester = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedAcademicYear,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                          ),
                          items: ['2023-24', '2024-25', '2025-26'].map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAcademicYear = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Course Input Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CourseInput(
                      onSubmit: (course) {
                        final updatedCourse = course.copyWith(
                          batch: _selectedBatch == BatchType.morning ? "B1" : "B2",
                          division: _selectedDivision,
                          classroom: _selectedClassroom,
                          program: _selectedProgram,
                          semester: _selectedSemester,
                          academicYear: _selectedAcademicYear,
                        );
                        provider.addCourse(updatedCourse);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Course added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Course List
                Text(
                  'Added Courses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                provider.courses.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No courses added yet.\nAdd courses using the form above.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final course in provider.courses)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CourseTile(
                                course: course,
                                onEdit: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit Course'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: CourseInput(
                                          course: course,
                                          onSubmit: (updatedCourse) {
                                            provider.updateCourse(updatedCourse);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Course updated successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  provider.removeCourse(course.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Course removed successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                const SizedBox(height: 16),
                // Generate Button
                ElevatedButton(
                  onPressed: provider.courses.isEmpty || _isGenerating
                      ? null
                      : () async {
                          setState(() => _isGenerating = true);
                          try {
                            final algorithm = GeneticAlgorithm(
                              courses: provider.courses,
                              batchType: _selectedBatch,
                              division: _selectedDivision,
                              classroom: _selectedClassroom,
                              academicYear: _selectedAcademicYear,
                              program: _selectedProgram,
                              semester: _selectedSemester,
                            );
                            final schedules = algorithm.generateSchedules();
                            provider.setSchedules(schedules);
                            if (mounted) {
                              context.go('/timetable');
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isGenerating = false);
                            }
                          }
                        },
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Generate Timetable'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 