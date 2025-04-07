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
    
    try {
      // Add metadata
      document.documentInformation.title = 'Timetable - ${schedule.program} ${schedule.semester}';
      document.documentInformation.author = 'TimeWise';
      document.documentInformation.creationDate = DateTime.now();
      
      // Create page with A4 landscape
      final PdfPage page = document.pages.add();
      final bounds = page.getClientSize();
      final double margin = 50;
      final double availableWidth = bounds.width - (2 * margin);
      final double cellWidth = availableWidth / 7;  // 7 columns (time + 6 days)
      final double cellHeight = 50;  // Increased height for better readability
      
      // Create fonts
      final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
      final subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
      final headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
      final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
      
      // Define colors
      final primaryColor = PdfColor(63, 81, 181);  // Material Indigo
      final headerBgColor = PdfColor(232, 234, 246);  // Light Indigo
      final breakBgColor = PdfColor(238, 238, 238);  // Light Grey
      final headerGradientColor = PdfColor(83, 70, 182);  // Blend of primary and secondary
      
      // Draw header section with solid background
      double yPos = margin;
      final headerHeight = 120.0;
      page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(margin, yPos, availableWidth, headerHeight),
        brush: PdfSolidBrush(headerGradientColor),
      );
      
      // Draw title and subtitle
      page.graphics.drawString(
        'School of Computer Sciences & Engineering',
        titleFont,
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        bounds: Rect.fromLTWH(margin + 20, yPos + 20, availableWidth - 40, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      
      page.graphics.drawString(
        'Department of Computer Science and Application',
        subtitleFont,
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        bounds: Rect.fromLTWH(margin + 20, yPos + 50, availableWidth - 40, 25),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      
      // Draw academic info
      page.graphics.drawString(
        'ACADEMIC YEAR: ${schedule.academicYear}',
        headerFont,
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        bounds: Rect.fromLTWH(margin + 20, yPos + 80, availableWidth - 40, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      
      yPos += headerHeight + 20;
      
      // Draw program info
      final infoText = 'Program: ${schedule.program}   Semester: ${schedule.semester}   Division: ${schedule.division}   Class Room: "${schedule.classroom}"';
      page.graphics.drawString(
        infoText,
        headerFont,
        bounds: Rect.fromLTWH(margin, yPos, availableWidth, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      
      yPos += 40;

      // Draw header row with styled cells
      final days = ['Time', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      for (int i = 0; i < days.length; i++) {
        page.graphics.drawRectangle(
          pen: PdfPen(primaryColor),
          brush: PdfSolidBrush(headerBgColor),
          bounds: Rect.fromLTWH(margin + (i * cellWidth), yPos, cellWidth, cellHeight),
        );
        page.graphics.drawString(
          days[i],
          headerFont,
          brush: PdfSolidBrush(primaryColor),
          bounds: Rect.fromLTWH(margin + (i * cellWidth), yPos, cellWidth, cellHeight),
          format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        );
      }
      yPos += cellHeight;

      // Draw grid with styled cells
      for (int row = 0; row < schedule.grid.length; row++) {
        // Draw time slot
        page.graphics.drawRectangle(
          pen: PdfPen(primaryColor),
          brush: PdfSolidBrush(headerBgColor),
          bounds: Rect.fromLTWH(margin, yPos, cellWidth, cellHeight),
        );
        page.graphics.drawString(
          schedule.grid[row][0].timeSlot,
          normalFont,
          brush: PdfSolidBrush(primaryColor),
          bounds: Rect.fromLTWH(margin, yPos, cellWidth, cellHeight),
          format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        );

        // Draw course cells
        for (int col = 0; col < schedule.grid[row].length; col++) {
          final cell = schedule.grid[row][col];
          final xPos = margin + ((col + 1) * cellWidth);
          
          // Set cell style based on content
          PdfColor bgColor;
          PdfColor textColor;
          String text;
          PdfFont font;
          
          if (cell.isBreak) {
            bgColor = breakBgColor;
            textColor = PdfColor(128, 128, 128);
            text = cell.breakType == 'Lunch Break' ? 'LUNCH BREAK' : 'SHORT BREAK';
            font = headerFont;
          } else if (cell.course == null) {
            bgColor = PdfColor(255, 255, 255);
            textColor = PdfColor(128, 128, 128);
            text = 'LIBRARY';
            font = headerFont;
          } else {
            // Convert Flutter color to PDF color
            final color = cell.course!.color;
            bgColor = PdfColor(
              color.red,
              color.green,
              color.blue,
              51,  // 0.2 * 255 = 51
            );
            textColor = PdfColor(
              color.red,
              color.green,
              color.blue,
            );
            text = '${cell.course!.name}\n${cell.course!.instructor ?? ''}';
            font = normalFont;
          }
          
          // Draw cell background
          page.graphics.drawRectangle(
            pen: PdfPen(cell.isConflict ? PdfColor(255, 0, 0) : primaryColor),
            brush: PdfSolidBrush(bgColor),
            bounds: Rect.fromLTWH(xPos, yPos, cellWidth, cellHeight),
          );
          
          // Draw cell text
          page.graphics.drawString(
            text,
            font,
            brush: PdfSolidBrush(textColor),
            bounds: Rect.fromLTWH(xPos, yPos, cellWidth, cellHeight),
            format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
          );
        }
        yPos += cellHeight;
      }
      
      // Add course legend
      yPos += 40;
      page.graphics.drawString(
        'Theory/Tutorial Course',
        headerFont,
        bounds: Rect.fromLTWH(margin, yPos, availableWidth, 20),
      );
      yPos += 30;
      
      // Draw theory courses table
      final theoryCourses = schedule.courses.where((c) => !c.isPractical).toList();
      if (theoryCourses.isNotEmpty) {
        // Table header
        for (var (i, title) in ['Course Code', 'Course Name', 'Full Name'].indexed) {
          page.graphics.drawRectangle(
            pen: PdfPen(primaryColor),
            brush: PdfSolidBrush(headerBgColor),
            bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
          );
          page.graphics.drawString(
            title,
            headerFont,
            brush: PdfSolidBrush(primaryColor),
            bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
            format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
          );
        }
        yPos += cellHeight;
        
        // Table rows
        for (final course in theoryCourses) {
          for (var (i, text) in [course.code, course.name, course.instructor ?? ''].indexed) {
            page.graphics.drawRectangle(
              pen: PdfPen(primaryColor),
              bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
            );
            page.graphics.drawString(
              text,
              normalFont,
              bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
              format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
            );
          }
          yPos += cellHeight;
        }
      }
      
      // Add practical courses section if there are any
      final practicalCourses = schedule.courses.where((c) => c.isPractical).toList();
      if (practicalCourses.isNotEmpty) {
        yPos += 20;
        page.graphics.drawString(
          'Practical Course',
          headerFont,
          bounds: Rect.fromLTWH(margin, yPos, availableWidth, 20),
        );
        yPos += 30;
        
        // Table header
        for (var (i, title) in ['Course Code', 'Course Name', 'Full Name'].indexed) {
          page.graphics.drawRectangle(
            pen: PdfPen(primaryColor),
            brush: PdfSolidBrush(headerBgColor),
            bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
          );
          page.graphics.drawString(
            title,
            headerFont,
            brush: PdfSolidBrush(primaryColor),
            bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
            format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
          );
        }
        yPos += cellHeight;
        
        // Table rows
        for (final course in practicalCourses) {
          for (var (i, text) in [course.code, course.name, course.instructor ?? ''].indexed) {
            page.graphics.drawRectangle(
              pen: PdfPen(primaryColor),
              bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
            );
            page.graphics.drawString(
              text,
              normalFont,
              bounds: Rect.fromLTWH(margin + (i * (availableWidth / 3)), yPos, availableWidth / 3, cellHeight),
              format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
            );
          }
          yPos += cellHeight;
        }
      }

      // Save and return the document
      final List<int> bytes = await document.save();
      document.dispose();
      return bytes;
    } catch (e) {
      document.dispose();
      throw Exception('Failed to generate PDF: $e');
    }
  }
} 