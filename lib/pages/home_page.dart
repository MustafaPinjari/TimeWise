import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../styles/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo or App Name
              Text(
                'Timewise',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                'Generate your academic timetable with intelligent schedule optimization',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Navigation Buttons
              ElevatedButton(
                onPressed: () => context.push('/generator'),
                child: const Text('Create New Timetable'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/timetable'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('View Existing Timetables'),
              ),
              const Spacer(),
              // Last Generated Info
              Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  if (provider.lastGenerated == null) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    'Last generated: ${provider.lastGenerated!.toString().split('.')[0]}',
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 