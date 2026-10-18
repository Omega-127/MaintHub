import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../api_client.dart';
import '../config/theme.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _client = ApiClient();

  /// Map raw department codes to human-readable names
  static String getDepartmentLabel(String? dept) {
    return switch (dept?.toUpperCase()) {
      'BLOWROOM'    => 'Blowroom',
      'COMBER'      => 'Comber',
      'RING_FRAME'  => 'Ring Frame',
      'SPEED_FRAME' => 'Speed Frame',
      'WINDING'     => 'Winding',
      'BUFFING'     => 'Buffing',
      _             => 'All Departments',
    };
  }

  /// Downloads the Excel file for a department and saves it to local device storage.
  /// Returns the saved [File].
  Future<File> downloadDepartmentExcel(String department) async {
    final response = await _client.getBytes('/machines/export?department=$department');
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Received empty file data from server.');
    }

    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final fileName = '${department.toUpperCase()}_Maintenance_Schedule_$dateStr.xlsx';

    // Determine target save directory
    Directory? targetDir;
    if (Platform.isAndroid) {
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (await publicDownload.exists()) {
        targetDir = publicDownload;
      }
    }

    targetDir ??= await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();

    final filePath = '${targetDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  /// Exports the Excel sheet and presents a SnackBar with an option to open the file.
  Future<void> exportAndPrompt(BuildContext context, String department) async {
    final deptLabel = getDepartmentLabel(department);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Text('Generating $deptLabel Excel sheet...'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primary,
      ),
    );

    try {
      final file = await downloadDepartmentExcel(department);

      if (!context.mounted) return;

      // Offer immediate open action
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deptLabel maintenance sheet exported!'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () {
              OpenFilex.open(file.path);
            },
          ),
        ),
      );

      // Attempt to launch viewer automatically
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export Excel: ${e.toString()}'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }
}
