# Timewise - Academic Timetable Generator

Timewise is a Flutter-based mobile and web application that helps students and educational institutions generate optimal academic timetables. Using a genetic algorithm, the app automatically creates multiple schedule options based on course details and available time slots, minimizes conflicts, and presents balanced schedules.

## Features

- **Course Management**
  - Add courses with details (name, instructor, credit hours)
  - Define multiple available time slots for each course
  - Color-code courses for easy identification
  - Edit and remove courses

- **Timetable Generation**
  - Intelligent schedule optimization using genetic algorithm
  - Multiple schedule options with fitness scores
  - Conflict detection and minimization
  - Balanced course distribution

- **Timetable Viewing**
  - Visual grid representation of schedules
  - Navigation between different schedule options
  - Course details and time slot information
  - Conflict highlighting

- **Export Functionality**
  - Export timetables to PDF
  - Preserve visual formatting and color coding
  - Include generation timestamp

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.0)
- Dart SDK (^3.7.0)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/timewise.git
   ```

2. Navigate to the project directory:
   ```bash
   cd timewise
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    // Entry point and route initialization
├── pages/
│   ├── home_page.dart           // Landing screen with introduction and navigation
│   ├── generator_page.dart      // Course input and timetable generation
│   └── timetable_page.dart      // Display of generated timetables
├── widgets/
│   ├── course_input.dart        // Form widget for course details
│   ├── timetable_view.dart      // Grid view for timetable display
│   └── course_tile.dart         // Reusable widget for course list items
├── models/
│   ├── course.dart              // Course model with properties
│   └── timetable_schedule.dart  // Model representing a generated schedule
├── utils/
│   ├── genetic_algorithm.dart   // Implementation of the genetic algorithm
│   ├── pdf_export.dart          // Utility functions for PDF export
│   └── storage_helper.dart      // Helper functions for local storage
└── styles/
    └── theme.dart               // Custom theme and styling definitions
```

## Usage

1. **Adding Courses**
   - Tap "Create New Timetable" on the home screen
   - Fill in course details (name, instructor, credit hours)
   - Choose a color for the course
   - Add one or more available time slots
   - Tap "Add Course" to save

2. **Generating Timetables**
   - Add all required courses
   - Tap "Generate Timetable" to start the optimization process
   - Wait for the algorithm to generate multiple schedule options

3. **Viewing and Exporting**
   - Navigate through generated schedules using arrow buttons
   - View course details and check for conflicts
   - Tap the download icon to export the current schedule as PDF

## Technical Details

### Genetic Algorithm

The timetable generation uses a genetic algorithm with the following parameters:
- Population size: 50
- Number of generations: 100
- Mutation rate: 0.1
- Crossover rate: 0.8

The fitness function considers:
- Number of conflicts
- Course distribution
- Time slot preferences

### Data Storage

The app uses `shared_preferences` for local storage of:
- Course data
- Generated schedules
- Last generation timestamp

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Contributors to the genetic algorithm research
- All the package maintainers whose work made this project possible
