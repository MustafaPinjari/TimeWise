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
    
    // Add metadata
    document.documentInformation.title = 'Timetable - ${schedule.program} ${schedule.semester}';
    document.documentInformation.author = 'TimeWise';
    
    // Create page with A4 landscape
    final PdfPage page = document.pages.add();
    final bounds = page.getClientSize();
    final double margin = 50;
    final double availableWidth = bounds.width - (2 * margin);
    final double cellWidth = availableWidth / 7;  // 7 columns (time + 6 days)
    final double cellHeight = 40;
    
    // Create fonts
    final headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    
    try {
      // Draw title
      double yPos = margin;
      page.graphics.drawString(
        'School of Computer Sciences & Engineering\nDepartment of Computer Science and Application',
        headerFont,
        bounds: Rect.fromLTWH(margin, yPos, availableWidth, 40),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      yPos += 50;

      // Draw header row
      final days = ['Time', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      for (int i = 0; i < days.length; i++) {
        page.graphics.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0)),
          brush: PdfSolidBrush(PdfColor(200, 200, 200)),
          bounds: Rect.fromLTWH(margin + (i * cellWidth), yPos, cellWidth, cellHeight),
        );
        page.graphics.drawString(
          days[i],
          headerFont,
          bounds: Rect.fromLTWH(margin + (i * cellWidth), yPos, cellWidth, cellHeight),
          format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        );
      }
      yPos += cellHeight;

      // Draw grid
      for (int row = 0; row < schedule.grid.length; row++) {
        // Draw time slot
        page.graphics.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0)),
          bounds: Rect.fromLTWH(margin, yPos, cellWidth, cellHeight),
        );
        page.graphics.drawString(
          schedule.grid[row][0].timeSlot,
          normalFont,
          bounds: Rect.fromLTWH(margin, yPos, cellWidth, cellHeight),
          format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        );

        // Draw course cells
        for (int col = 0; col < schedule.grid[row].length; col++) {
          final cell = schedule.grid[row][col];
          final xPos = margin + ((col + 1) * cellWidth);
          
          page.graphics.drawRectangle(
            pen: PdfPen(PdfColor(0, 0, 0)),
            bounds: Rect.fromLTWH(xPos, yPos, cellWidth, cellHeight),
          );

          String text;
          if (cell.isBreak) {
            text = cell.breakType == 'Lunch Break' ? 'LUNCH BREAK' : 'SHORT BREAK';
          } else if (cell.course == null) {
            text = 'LIBRARY';
          } else {
            text = '${cell.course!.name}\n${cell.course!.instructor ?? ''}';
          }

          page.graphics.drawString(
            text,
            normalFont,
            bounds: Rect.fromLTWH(xPos, yPos, cellWidth, cellHeight),
            format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
          );
        }
        yPos += cellHeight;
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