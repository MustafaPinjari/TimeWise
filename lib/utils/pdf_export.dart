import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/timetable_schedule.dart';
import '../models/course.dart';

class PdfExport {
  static Future<List<int>> exportTimetable(TimetableSchedule schedule) async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Define page settings
    final Size pageSize = page.getClientSize();
    final double timeColumnWidth = 150;
    final double dayColumnWidth = 200;
    final double cellHeight = 60;
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    // Draw header
    double currentY = 20;
    page.graphics.drawString(
      'School of Computer Sciences & Engineering',
      titleFont,
      bounds: Rect.fromLTWH(0, currentY, pageSize.width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 30;

    page.graphics.drawString(
      'Department of Computer Science and Application',
      headerFont,
      bounds: Rect.fromLTWH(0, currentY, pageSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 25;

    page.graphics.drawString(
      'ACADEMIC YEAR: ${schedule.academicYear}',
      headerFont,
      bounds: Rect.fromLTWH(0, currentY, pageSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 25;

    // Program info row
    final String programInfo = 'Program: ${schedule.program}    Semester: ${schedule.semester}    Division: ${schedule.division}';
    page.graphics.drawString(
      programInfo,
      normalFont,
      bounds: Rect.fromLTWH(50, currentY, pageSize.width - 100, 20),
    );
    currentY += 20;

    page.graphics.drawString(
      'Class Room: "${schedule.classroom}"',
      normalFont,
      bounds: Rect.fromLTWH(50, currentY, pageSize.width - 100, 20),
    );
    currentY += 30;

    // Draw timetable grid
    final List<String> days = ['Time', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final List<String> timeSlots = [
      '8:00 AM - 9:00 AM',
      '9:00 AM - 10:00 AM',
      '10:00 AM - 10:15 AM',  // Short Break
      '10:15 AM - 11:15 AM',
      '11:15 AM - 12:15 PM',
      '12:15 PM - 1:00 PM',   // Lunch Break
      '1:00 PM - 2:00 PM',
      '2:00 PM - 3:00 PM',
    ];

    // Draw header row
    double currentX = 50;
    for (int i = 0; i < days.length; i++) {
      final width = i == 0 ? timeColumnWidth : dayColumnWidth;
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0)),
        brush: PdfSolidBrush(PdfColor(240, 240, 240)),
        bounds: Rect.fromLTWH(currentX, currentY, width, cellHeight),
      );
      page.graphics.drawString(
        days[i],
        headerFont,
        bounds: Rect.fromLTWH(currentX + 5, currentY + 5, width - 10, cellHeight - 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
      );
      currentX += width;
    }
    currentY += cellHeight;

    // Draw time slots and courses
    for (int row = 0; row < timeSlots.length; row++) {
      currentX = 50;
      
      // Draw time column
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0)),
        brush: PdfSolidBrush(PdfColor(240, 240, 240)),
        bounds: Rect.fromLTWH(currentX, currentY, timeColumnWidth, cellHeight),
      );
      page.graphics.drawString(
        timeSlots[row],
        normalFont,
        bounds: Rect.fromLTWH(currentX + 5, currentY + 5, timeColumnWidth - 10, cellHeight - 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
      );
      currentX += timeColumnWidth;

      // Draw course cells
      for (int col = 0; col < 6; col++) {
        final cell = schedule.grid[row][col];
        
        page.graphics.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0)),
          bounds: Rect.fromLTWH(currentX, currentY, dayColumnWidth, cellHeight),
        );

        String text;
        if (cell.isBreak) {
          text = cell.breakType == 'Lunch Break' ? 'LUNCH BREAK' : 'SHORT BREAK';
          page.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(240, 240, 240)),
            bounds: Rect.fromLTWH(currentX, currentY, dayColumnWidth, cellHeight),
          );
        } else if (cell.course == null) {
          text = 'LIBRARY';
        } else {
          text = '${cell.course!.name}\n${cell.course!.instructor ?? ''}';
          final color = cell.course!.color;
          page.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(color.red, color.green, color.blue, 40)),
            bounds: Rect.fromLTWH(currentX, currentY, dayColumnWidth, cellHeight),
          );
        }

        page.graphics.drawString(
          text,
          normalFont,
          bounds: Rect.fromLTWH(currentX + 5, currentY + 5, dayColumnWidth - 10, cellHeight - 10),
          format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        );

        currentX += dayColumnWidth;
      }
      currentY += cellHeight;
    }

    // Draw course tables
    currentY += 30;
    
    // Theory/Tutorial Courses
    page.graphics.drawString(
      'Theory/Tutorial Course',
      headerFont,
      bounds: Rect.fromLTWH(50, currentY, pageSize.width - 100, 20),
    );
    currentY += 25;

    final theoryCourses = schedule.courses.where((c) => !c.isPractical).toList();
    if (theoryCourses.isNotEmpty) {
      currentY = _drawCourseTable(page, theoryCourses, currentY);
    }

    currentY += 30;

    // Practical Courses
    page.graphics.drawString(
      'Practical Course',
      headerFont,
      bounds: Rect.fromLTWH(50, currentY, pageSize.width - 100, 20),
    );
    currentY += 25;

    final practicalCourses = schedule.courses.where((c) => c.isPractical).toList();
    if (practicalCourses.isNotEmpty) {
      currentY = _drawCourseTable(page, practicalCourses, currentY);
    }

    // Save the document
    final List<int> bytes = await document.save();
    document.dispose();
    return bytes;
  }

  static double _drawCourseTable(PdfPage page, List<Course> courses, double startY) {
    final double columnWidth = (page.getClientSize().width - 100) / 3;
    final double rowHeight = 30;
    double currentY = startY;

    // Draw header
    for (int i = 0; i < 3; i++) {
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0)),
        brush: PdfSolidBrush(PdfColor(240, 240, 240)),
        bounds: Rect.fromLTWH(50 + (i * columnWidth), currentY, columnWidth, rowHeight),
      );
    }

    final headerFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    page.graphics.drawString(
      'Course Code',
      headerFont,
      bounds: Rect.fromLTWH(55, currentY + 5, columnWidth - 10, rowHeight - 10),
    );
    page.graphics.drawString(
      'Course Name',
      headerFont,
      bounds: Rect.fromLTWH(55 + columnWidth, currentY + 5, columnWidth - 10, rowHeight - 10),
    );
    page.graphics.drawString(
      'Full Name',
      headerFont,
      bounds: Rect.fromLTWH(55 + (2 * columnWidth), currentY + 5, columnWidth - 10, rowHeight - 10),
    );
    currentY += rowHeight;

    // Draw rows
    final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    for (final course in courses) {
      for (int i = 0; i < 3; i++) {
        page.graphics.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0)),
          bounds: Rect.fromLTWH(50 + (i * columnWidth), currentY, columnWidth, rowHeight),
        );
      }

      page.graphics.drawString(
        course.code,
        normalFont,
        bounds: Rect.fromLTWH(55, currentY + 5, columnWidth - 10, rowHeight - 10),
      );
      page.graphics.drawString(
        course.name,
        normalFont,
        bounds: Rect.fromLTWH(55 + columnWidth, currentY + 5, columnWidth - 10, rowHeight - 10),
      );
      page.graphics.drawString(
        course.instructor ?? '',
        normalFont,
        bounds: Rect.fromLTWH(55 + (2 * columnWidth), currentY + 5, columnWidth - 10, rowHeight - 10),
      );
      currentY += rowHeight;
    }

    return currentY;
  }
} 