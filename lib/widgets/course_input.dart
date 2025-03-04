import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/course.dart';

class CourseInput extends StatefulWidget {
  final Course? course;
  final Function(Course) onSubmit;

  const CourseInput({
    super.key,
    this.course,
    required this.onSubmit,
  });

  @override
  State<CourseInput> createState() => _CourseInputState();
}

class _CourseInputState extends State<CourseInput> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _instructorController;
  late TextEditingController _creditHoursController;
  late Color _selectedColor;
  final List<TimeSlot> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course?.name);
    _instructorController = TextEditingController(text: widget.course?.instructor);
    _creditHoursController = TextEditingController(
      text: widget.course?.creditHours.toString(),
    );
    _selectedColor = widget.course?.color ?? Colors.blue;
    if (widget.course != null) {
      _timeSlots.addAll(widget.course!.availableTimeSlots);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _creditHoursController.dispose();
    super.dispose();
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

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _timeSlots.isNotEmpty) {
      _formKey.currentState!.save();
      
      final course = Course(
        id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        instructor: _instructorController.text.isEmpty
            ? null
            : _instructorController.text,
        creditHours: int.parse(_creditHoursController.text),
        color: _selectedColor,
        availableTimeSlots: List.from(_timeSlots),
      );

      widget.onSubmit(course);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Course Name',
              hintText: 'e.g., Introduction to Computer Science',
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
              hintText: 'e.g., Dr. John Smith',
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
                    child: ColorPicker(
                      pickerColor: _selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Time Slots
          Text(
            'Available Time Slots',
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
                  onPressed: () => _removeTimeSlot(index),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _addTimeSlot,
            icon: const Icon(Icons.add),
            label: const Text('Add Time Slot'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.course == null ? 'Add Course' : 'Update Course'),
          ),
        ],
      ),
    );
  }
} 