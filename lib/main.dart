import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// Only import web plugins when running on web
// Remove direct import of flutter_web_plugins
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'styles/theme.dart';
import 'pages/home_page.dart';
import 'pages/generator_page.dart';
import 'pages/timetable_page.dart';
import 'models/course.dart';
import 'models/timetable_schedule.dart';
import 'utils/storage_helper.dart';
import 'widgets/logo.dart';

// Use conditional import for web platform
// We'll import this only when compiling for web
import 'web_url_strategy.dart' if (dart.library.io) 'stub_url_strategy.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Configure web specific settings
    if (kIsWeb) {
      // Call the platform-independent function
      configureUrl();
    }
    
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = CourseProvider();
        provider.loadData(); // Load saved data when app starts
        return provider;
      },
      child: MaterialApp.router(
        title: 'Timewise',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: const TimeWiseLogo(size: 32),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/generator',
          builder: (context, state) => const GeneratorPage(),
        ),
        GoRoute(
          path: '/timetable',
          builder: (context, state) => const TimetablePage(),
        ),
      ],
    ),
  ],
);

class CourseProvider extends ChangeNotifier {
  List<Course> _courses = [];
  List<TimetableSchedule> _schedules = [];
  DateTime? _lastGenerated;

  List<Course> get courses => _courses;
  List<TimetableSchedule> get schedules => _schedules;
  DateTime? get lastGenerated => _lastGenerated;

  Future<void> loadData() async {
    _courses = await StorageHelper.loadCourses();
    _schedules = await StorageHelper.loadSchedules(_courses);
    _lastGenerated = await StorageHelper.loadLastGenerated();
    notifyListeners();
  }

  Future<void> saveData() async {
    await StorageHelper.saveCourses(_courses);
    await StorageHelper.saveSchedules(_schedules);
    if (_lastGenerated != null) {
      await StorageHelper.saveLastGenerated(_lastGenerated!);
    }
  }

  void addCourse(Course course) {
    _courses.add(course);
    saveData();
    notifyListeners();
  }

  void updateCourse(Course course) {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      saveData();
      notifyListeners();
    }
  }

  void removeCourse(String courseId) {
    _courses.removeWhere((course) => course.id == courseId);
    saveData();
    notifyListeners();
  }

  void setSchedules(List<TimetableSchedule> schedules) {
    _schedules = schedules;
    _lastGenerated = DateTime.now();
    saveData();
    notifyListeners();
  }

  void clearAll() async {
    _courses = [];
    _schedules = [];
    _lastGenerated = null;
    await StorageHelper.clearAll();
    notifyListeners();
  }
}
