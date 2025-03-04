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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Timewise',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Generate your academic timetable with intelligent schedule optimization',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textLightColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Stats Section
                Consumer<CourseProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          context,
                          'Courses',
                          provider.courses.length.toString(),
                          Icons.book,
                        ),
                        _buildStatCard(
                          context,
                          'Schedules',
                          provider.schedules.length.toString(),
                          Icons.calendar_today,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        'Create New Timetable',
                        'Generate a new optimized schedule for your courses',
                        Icons.add_circle_outline,
                        () => context.push('/generator'),
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        'View Timetables',
                        'Browse and manage your generated schedules',
                        Icons.view_agenda_outlined,
                        () => context.push('/timetable'),
                        AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Last Generated Info
                Consumer<CourseProvider>(
                  builder: (context, provider, child) {
                    if (provider.lastGenerated == null) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textLightColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last generated: ${provider.lastGenerated!.toString().split('.')[0]}',
                            style: TextStyle(
                              color: AppTheme.textLightColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLightColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 