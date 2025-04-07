import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../utils/genetic_algorithm.dart';
import '../widgets/course_input.dart';
import '../widgets/course_tile.dart';
import '../models/course.dart';
import '../styles/theme.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<CourseProvider>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Generate Timetable'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.schedule,
                        size: 64,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                ),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Batch Settings Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Timetable Settings',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Batch Selection with Custom Design
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppTheme.surfaceColor,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Select Batch',
                                          style: TextStyle(
                                            color: AppTheme.textColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RadioListTile<BatchType>(
                                              title: const Text('Morning\n8:00 AM - 3:00 PM'),
                                              value: BatchType.morning,
                                              groupValue: _selectedBatch,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedBatch = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<BatchType>(
                                              title: const Text('Afternoon\n10:00 AM - 5:00 PM'),
                                              value: BatchType.afternoon,
                                              groupValue: _selectedBatch,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedBatch = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Division and Classroom in a Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _selectedDivision,
                                        decoration: InputDecoration(
                                          labelText: 'Division',
                                          hintText: 'e.g., B',
                                          prefixIcon: Icon(Icons.group, color: AppTheme.primaryColor),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDivision = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _selectedClassroom,
                                        decoration: InputDecoration(
                                          labelText: 'Classroom',
                                          hintText: 'e.g., S-C3',
                                          prefixIcon: Icon(Icons.meeting_room, color: AppTheme.primaryColor),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedClassroom = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Program Dropdown with Icon
                                DropdownButtonFormField<String>(
                                  value: _selectedProgram,
                                  decoration: InputDecoration(
                                    labelText: 'Program',
                                    prefixIcon: Icon(Icons.school, color: AppTheme.primaryColor),
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
                                const SizedBox(height: 20),
                                // Semester and Academic Year in a Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedSemester,
                                        decoration: InputDecoration(
                                          labelText: 'Semester',
                                          prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
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
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedAcademicYear,
                                        decoration: InputDecoration(
                                          labelText: 'Academic Year',
                                          prefixIcon: Icon(Icons.date_range, color: AppTheme.primaryColor),
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Added Courses List
                        if (provider.courses.isNotEmpty) Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.list,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Added Courses',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.courses.length,
                                  itemBuilder: (context, index) {
                                    final course = provider.courses[index];
                                    return CourseTile(
                                      course: course,
                                      onEdit: () {
                                        // Show edit dialog
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Edit Course'),
                                            content: SingleChildScrollView(
                                              child: CourseInput(
                                                course: course,
                                                onSubmit: (updatedCourse) {
                                                  provider.updateCourse(updatedCourse);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      onDelete: () {
                                        // Show delete confirmation
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Course'),
                                            content: Text('Are you sure you want to delete ${course.name}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  provider.removeCourse(course.id);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Course Input Form with Modern Design
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Add Course',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                CourseInput(
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
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isGenerating = true);
            
            try {
              final provider = context.read<CourseProvider>();
              if (provider.courses.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add at least one course before generating a timetable'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

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
              if (schedules.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not generate a valid timetable. Please check your course configurations.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              provider.setSchedules(schedules);
              if (mounted) {
                context.push('/timetable');
              }
            } finally {
              if (mounted) {
                setState(() => _isGenerating = false);
              }
            }
          }
        },
        icon: _isGenerating 
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.schedule),
        label: Text(_isGenerating ? 'Generating...' : 'Generate Timetable'),
      ),
    );
  }
} 