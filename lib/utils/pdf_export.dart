import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/timetable_schedule.dart';

class PdfExport {
  static Future<List<int>> exportTimetable(TimetableSchedule schedule) async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Define page settings
    final Size pageSize = page.getClientSize();
    final double cellWidth = (pageSize.width - 100) / 6; // Time column + 5 days
    final double cellHeight = 50;
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 20);
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont cellFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    // Draw title
    page.graphics.drawString(
      'Class Schedule',
      titleFont,
      bounds: Rect.fromLTWH(0, 0, pageSize.width, 60),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Draw header row
    final List<String> days = ['Time', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    for (int i = 0; i < days.length; i++) {
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0)),
        brush: PdfSolidBrush(PdfColor(240, 240, 240)),
        bounds: Rect.fromLTWH(
          i * cellWidth,
          60,
          cellWidth,
          cellHeight,
        ),
      );
      page.graphics.drawString(
        days[i],
        headerFont,
        bounds: Rect.fromLTWH(
          i * cellWidth,
          60,
          cellWidth,
          cellHeight,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
      );
    }

    // Draw time slots and courses
    for (int row = 0; row < 12; row++) {
      // Draw time column
      final timeY = 60 + (row + 1) * cellHeight;
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0)),
        brush: PdfSolidBrush(PdfColor(240, 240, 240)),
        bounds: Rect.fromLTWH(0, timeY, cellWidth, cellHeight),
      );
      page.graphics.drawString(
        '${row + 8}:00',
        cellFont,
        bounds: Rect.fromLTWH(0, timeY, cellWidth, cellHeight),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
      );

      // Draw course cells
      for (int col = 0; col < 5; col++) {
        final cell = schedule.grid[row][col];
        final cellX = (col + 1) * cellWidth;
        
        // Draw cell border
        page.graphics.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0)),
          bounds: Rect.fromLTWH(cellX, timeY, cellWidth, cellHeight),
        );

        if (cell.course != null) {
          // Draw course info
          final Color color = cell.course!.color;
          page.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(
              color.red,
              color.green,
              color.blue,
              40, // 20% opacity
            )),
            bounds: Rect.fromLTWH(cellX, timeY, cellWidth, cellHeight),
          );

          // Course name and details
          final courseInfo = [
            cell.course!.name,
            if (cell.course!.instructor != null) cell.course!.instructor!,
            if (cell.timeSlot != null)
              '${_formatTime(cell.timeSlot!.startTime)} - ${_formatTime(cell.timeSlot!.endTime)}',
          ].join('\n');

          page.graphics.drawString(
            courseInfo,
            cellFont,
            bounds: Rect.fromLTWH(cellX + 5, timeY + 5, cellWidth - 10, cellHeight - 10),
            format: PdfStringFormat(alignment: PdfTextAlignment.left),
          );
        }
      }
    }

    // Add footer with generation info
    final footerText = 'Generated on ${DateTime.now().toString()}\nFitness Score: ${(schedule.fitnessScore * 100).toStringAsFixed(1)}%';
    page.graphics.drawString(
      footerText,
      cellFont,
      bounds: Rect.fromLTWH(0, pageSize.height - 40, pageSize.width, 40),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // Save the document
    final List<int> bytes = await document.save();
    document.dispose();
    return bytes;
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 