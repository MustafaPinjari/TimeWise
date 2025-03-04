import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructorController = TextEditingController();
  final _creditHoursController = TextEditingController();
  Color _selectedColor = Colors.blue;
  final List<TimeSlot> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    // Load data when page initializes
    context.read<CourseProvider>().loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _creditHoursController.dispose();
    super.dispose();
  }

  void _addCourse() {
    if (_formKey.currentState!.validate() && _timeSlots.isNotEmpty) {
      debugPrint('Adding course: ${_nameController.text}');
      final course = Course(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        instructor: _instructorController.text.isEmpty ? null : _instructorController.text,
        creditHours: int.parse(_creditHoursController.text),
        color: _selectedColor,
        availableTimeSlots: List.from(_timeSlots),
      );

      context.read<CourseProvider>().addCourse(course);
      debugPrint('Course added successfully');

      // Clear form
      _nameController.clear();
      _instructorController.clear();
      _creditHoursController.clear();
      setState(() {
        _timeSlots.clear();
        _selectedColor = Colors.blue;
      });
      _formKey.currentState!.reset();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      debugPrint('Form validation failed or no time slots added');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and add at least one time slot'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addTimeSlot() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 1,
        minute: startTime.minute,
      ),
    );

    if (endTime == null) return;

    final int? day = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 5; i++)
              ListTile(
                title: Text([
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday'
                ][i]),
                onTap: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );

    if (day == null) return;

    setState(() {
      _timeSlots.add(TimeSlot(
        day: day,
        startTime: startTime,
        endTime: endTime,
      ));
    });
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
                // Course Input Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Course Name',
                              hintText: 'e.g., Operating Systems',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a course name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _instructorController,
                            decoration: const InputDecoration(
                              labelText: 'Instructor (Optional)',
                              hintText: 'e.g., Dr. Smith',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _creditHoursController,
                            decoration: const InputDecoration(
                              labelText: 'Credit Hours',
                              hintText: 'e.g., 3',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter credit hours';
                              }
                              final number = int.tryParse(value);
                              if (number == null || number <= 0) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Color Picker
                          ListTile(
                            title: const Text('Course Color'),
                            trailing: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Pick a color'),
                                  content: SingleChildScrollView(
                                    child: BlockPicker(
                                      pickerColor: _selectedColor,
                                      onColorChanged: (color) {
                                        setState(() {
                                          _selectedColor = color;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Time Slots
                          Text(
                            'Time Slots',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _timeSlots.length,
                            itemBuilder: (context, index) {
                              final slot = _timeSlots[index];
                              return ListTile(
                                title: Text([
                                  'Monday',
                                  'Tuesday',
                                  'Wednesday',
                                  'Thursday',
                                  'Friday'
                                ][slot.day]),
                                subtitle: Text(
                                  '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _timeSlots.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _addTimeSlot,
                            icon: const Icon(Icons.access_time),
                            label: const Text('Add Time Slot'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _timeSlots.isEmpty ? null : _addCourse,
                            child: const Text('Add Course'),
                          ),
                        ],
                      ),
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
                            'No courses added yet.\nFill the form above to add a course.',
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
                                  // TODO: Implement edit functionality
                                  debugPrint('Editing course: ${course.name}');
                                },
                                onDelete: () {
                                  debugPrint('Deleting course: ${course.name}');
                                  provider.removeCourse(course.id);
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
                              rows: 12, // 8 AM to 8 PM
                              columns: 5, // Monday to Friday
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