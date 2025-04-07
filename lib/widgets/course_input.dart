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
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _instructorController;
  late TextEditingController _creditHoursController;
  late TextEditingController _classroomController;
  late TextEditingController _divisionController;
  late TextEditingController _rollStartController;
  late TextEditingController _rollEndController;
  late TextEditingController _studentCountController;
  late Color _selectedColor;
  late BatchType _selectedBatch;
  late SlotType _selectedType;
  late CourseType _selectedCourseType;
  late String _selectedProgram;
  late String _selectedSemester;
  late String _selectedAcademicYear;
  final List<TimeSlot> _timeSlots = [];

  // Predefined options
  final List<String> _programs = ['BCA', 'MCA', 'B.Tech', 'M.Tech'];
  final List<String> _semesters = ['Sem-I', 'Sem-II', 'Sem-III', 'Sem-IV', 'Sem-V', 'Sem-VI'];
  final List<String> _academicYears = ['2023-24', '2024-25', '2025-26'];

  // Add focus nodes for each text field
  final _codeFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _instructorFocus = FocusNode();
  final _creditHoursFocus = FocusNode();
  final _rollStartFocus = FocusNode();
  final _rollEndFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.course?.code);
    _nameController = TextEditingController(text: widget.course?.name);
    _instructorController = TextEditingController(text: widget.course?.instructor);
    _creditHoursController = TextEditingController(text: widget.course?.creditHours.toString());
    _classroomController = TextEditingController(text: widget.course?.classroom);
    _divisionController = TextEditingController(text: widget.course?.division);
    _rollStartController = TextEditingController(text: widget.course?.rollNumberStart.toString());
    _rollEndController = TextEditingController(text: widget.course?.rollNumberEnd.toString());
    _studentCountController = TextEditingController(text: widget.course?.studentCount.toString());
    _selectedColor = widget.course?.color ?? Colors.blue;
    _selectedBatch = widget.course?.batch == "B2" ? BatchType.afternoon : BatchType.morning;
    _selectedType = widget.course?.type ?? SlotType.lecture;
    _selectedCourseType = widget.course?.courseType ?? CourseType.theory;
    _selectedProgram = widget.course?.program ?? _programs.first;
    _selectedSemester = widget.course?.semester ?? _semesters.first;
    _selectedAcademicYear = widget.course?.academicYear ?? _academicYears.first;
    if (widget.course != null) {
      _timeSlots.addAll(widget.course!.availableTimeSlots);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _instructorController.dispose();
    _creditHoursController.dispose();
    _classroomController.dispose();
    _divisionController.dispose();
    _rollStartController.dispose();
    _rollEndController.dispose();
    _studentCountController.dispose();
    _codeFocus.dispose();
    _nameFocus.dispose();
    _instructorFocus.dispose();
    _creditHoursFocus.dispose();
    _rollStartFocus.dispose();
    _rollEndFocus.dispose();
    super.dispose();
  }

  // Field focus change helper
  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _addTimeSlot() async {
    // Get batch time range
    final batchStartHour = _selectedBatch == BatchType.morning ? 8 : 10;
    final batchEndHour = _selectedBatch == BatchType.morning ? 15 : 17;

    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: batchStartHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (startTime == null) return;

    // Validate start time
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final batchStartMinutes = batchStartHour * 60;
    final batchEndMinutes = batchEndHour * 60;

    if (startMinutes < batchStartMinutes || startMinutes >= batchEndMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Start time must be between ${batchStartHour}:00 AM and ${batchEndHour}:00 PM'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (startTime.hour + 1) > batchEndHour ? batchEndHour : (startTime.hour + 1),
        minute: startTime.minute,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (endTime == null) return;

    // Validate end time
    final endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes || endMinutes > batchEndMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid end time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check for break time conflicts
    final shortBreakStart = (_selectedBatch == BatchType.morning ? 10 : 12) * 60;
    final shortBreakEnd = shortBreakStart + 15;
    final lunchBreakStart = (_selectedBatch == BatchType.morning ? 12 : 14) * 60;
    final lunchBreakEnd = lunchBreakStart + 45;

    if ((startMinutes < shortBreakEnd && endMinutes > shortBreakStart) ||
        (startMinutes < lunchBreakEnd && endMinutes > lunchBreakStart)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot cannot overlap with break times'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final int? day = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 6; i++)
              ListTile(
                title: Text([
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday'
                ][i]),
                onTap: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );

    if (day == null) return;

    // Check for overlapping slots on the same day
    final hasOverlap = _timeSlots.any((slot) {
      if (slot.day != day) return false;
      final slotStart = slot.startTime.hour * 60 + slot.startTime.minute;
      final slotEnd = slot.endTime.hour * 60 + slot.endTime.minute;
      return (startMinutes < slotEnd && endMinutes > slotStart);
    });

    if (hasOverlap) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot overlaps with an existing slot'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _timeSlots.add(TimeSlot(
        day: day,
        startTime: startTime,
        endTime: endTime,
        type: _selectedType,
      ));
    });
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  void _clearForm() {
    _codeController.clear();
    _nameController.clear();
    _instructorController.clear();
    _creditHoursController.clear();
    _classroomController.clear();
    _divisionController.clear();
    _rollStartController.clear();
    _rollEndController.clear();
    _studentCountController.clear();
    setState(() {
      _selectedColor = Colors.blue;
      _selectedBatch = BatchType.morning;
      _selectedType = SlotType.lecture;
      _selectedCourseType = CourseType.theory;
      _selectedProgram = _programs.first;
      _selectedSemester = _semesters.first;
      _selectedAcademicYear = _academicYears.first;
      _timeSlots.clear();
    });
  }

  void _updateStudentCount() {
    final start = int.tryParse(_rollStartController.text);
    final end = int.tryParse(_rollEndController.text);
    
    if (start != null && end != null && end >= start) {
      setState(() {
        _studentCountController.text = (end - start + 1).toString();
      });
    } else {
      _studentCountController.text = '';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _timeSlots.isNotEmpty) {
      _formKey.currentState!.save();
      
      final course = Course(
        id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        code: _codeController.text,
        name: _nameController.text,
        instructor: _instructorController.text.isEmpty ? null : _instructorController.text,
        creditHours: int.parse(_creditHoursController.text),
        color: _selectedColor,
        availableTimeSlots: List.from(_timeSlots),
        type: _selectedType,
        classroom: _classroomController.text,
        division: _divisionController.text,
        batch: _selectedBatch == BatchType.morning ? "B1" : "B2",
        program: _selectedProgram,
        semester: _selectedSemester,
        courseType: _selectedCourseType,
        rollNumberStart: int.parse(_rollStartController.text),
        rollNumberEnd: int.parse(_rollEndController.text),
        studentCount: int.parse(_studentCountController.text),
        academicYear: _selectedAcademicYear,
        isPractical: _selectedCourseType == CourseType.practical,
      );

      widget.onSubmit(course);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${course.name} has been added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Clear form if not in edit mode
      if (widget.course == null) {
        _clearForm();
      }
    } else if (_timeSlots.isEmpty) {
      // Show error message if no time slots added
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one time slot'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Basic Course Information
          Text(
            'Course Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codeController,
            focusNode: _codeFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _codeFocus, _nameFocus),
            decoration: const InputDecoration(
              labelText: 'Course Code',
              hintText: 'e.g., XCA403',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a course code';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _nameFocus, _instructorFocus),
            decoration: const InputDecoration(
              labelText: 'Course Name',
              hintText: 'e.g., Software Project Management',
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
            focusNode: _instructorFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _instructorFocus, _creditHoursFocus),
            decoration: const InputDecoration(
              labelText: 'Instructor',
              hintText: 'e.g., Dr. John Smith',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _creditHoursController,
            focusNode: _creditHoursFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _creditHoursFocus, _rollStartFocus),
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
          const SizedBox(height: 24),

          // Course Type and Schedule
          Text(
            'Course Type and Schedule',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CourseType>(
            value: _selectedCourseType,
            decoration: const InputDecoration(
              labelText: 'Course Type',
            ),
            items: CourseType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCourseType = value!;
                // Update slot type based on course type
                _selectedType = switch (value) {
                  CourseType.theory => SlotType.lecture,
                  CourseType.practical => SlotType.practical,
                  CourseType.vap => SlotType.vap,
                  CourseType.training => SlotType.training,
                  CourseType.library => SlotType.library,
                };
              });
            },
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
          const SizedBox(height: 24),

          // Academic Information
          Text(
            'Academic Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedProgram,
            decoration: const InputDecoration(
              labelText: 'Program',
            ),
            items: _programs.map((program) {
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
            items: _semesters.map((semester) {
              return DropdownMenuItem(
                value: semester,
                child: Text(semester),
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
            items: _academicYears.map((year) {
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
          const SizedBox(height: 24),

          // Class and Student Information
          Text(
            'Student Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rollStartController,
                  focusNode: _rollStartFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _fieldFocusChange(context, _rollStartFocus, _rollEndFocus),
                  decoration: const InputDecoration(
                    labelText: 'Roll Number Start',
                    hintText: 'e.g., 101',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final start = int.tryParse(value);
                    if (start == null || start < 0) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _updateStudentCount();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _rollEndController,
                  focusNode: _rollEndFocus,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _rollEndFocus.unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Roll Number End',
                    hintText: 'e.g., 150',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final end = int.tryParse(value);
                    if (end == null || end < 0) {
                      return 'Invalid number';
                    }
                    final start = int.tryParse(_rollStartController.text);
                    if (start != null && end < start) {
                      return 'Must be >= start';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _updateStudentCount();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _studentCountController,
            decoration: const InputDecoration(
              labelText: 'Number of Students',
              hintText: 'Auto-calculated from roll numbers',
            ),
            enabled: false,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          // Color Selection
          Text(
            'Course Color',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Select Color'),
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
          const SizedBox(height: 24),

          // Time Slots
          Text(
            'Time Slots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
                  'Friday',
                  'Saturday'
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
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.course == null ? 'Add Course' : 'Update Course'),
          ),
        ],
      ),
    );
  }
} 