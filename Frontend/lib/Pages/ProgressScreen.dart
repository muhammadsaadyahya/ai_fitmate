import 'package:ai_fitmate/components/topSnackBar.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:csv/csv.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedPeriodIndex = 0; // 0: Week, 1: Month, 2: Year
  final ScreenshotController _screenshotController = ScreenshotController();

  // Dummy data
  final List<String> periods = ['Week', 'Month', 'Year'];

  // Data for different periods
  final Map<String, Map<String, dynamic>> periodData = {
    'Week': {
      'workouts': 5,
      'minutes': 142,
      'minutesGoal': 180,
      'calories': 3450,
      'streak': 7,
      'activity': [30, 45, 60, 40, 55, 50, 35],
      'activityLabels': ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      'sessions': [
        {
          'title': 'Upper Body Strength',
          'icon': Icons.fitness_center,
          'duration': '45 min',
          'calories': '320 kcal',
          'time': '7:30 AM',
        },
        {
          'title': 'Endurance Run',
          'icon': Icons.directions_run,
          'duration': '30 min',
          'calories': '280 kcal',
          'time': 'Yesterday',
        },
        {
          'title': 'Mobility Flow',
          'icon': Icons.self_improvement,
          'duration': '15 min',
          'calories': '90 kcal',
          'time': 'Tue',
        },
      ],
    },
    'Month': {
      'workouts': 22,
      'minutes': 680,
      'minutesGoal': 720,
      'calories': 15200,
      'streak': 7,
      'activity': [120, 140, 160, 180],
      'activityLabels': ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
      'sessions': [
        {
          'title': 'Upper Body Strength',
          'icon': Icons.fitness_center,
          'duration': '45 min',
          'calories': '320 kcal',
          'time': 'Today',
        },
        {
          'title': 'Full Body HIIT',
          'icon': Icons.flash_on,
          'duration': '35 min',
          'calories': '400 kcal',
          'time': '2 days ago',
        },
        {
          'title': 'Yoga Session',
          'icon': Icons.self_improvement,
          'duration': '50 min',
          'calories': '180 kcal',
          'time': '4 days ago',
        },
        {
          'title': 'Cardio Blast',
          'icon': Icons.directions_run,
          'duration': '40 min',
          'calories': '380 kcal',
          'time': '1 week ago',
        },
      ],
    },
    'Year': {
      'workouts': 264,
      'minutes': 8520,
      'minutesGoal': 8640,
      'calories': 182400,
      'streak': 7,
      'activity': [600, 650, 720, 680, 710, 690, 740, 700, 730, 680, 720, 760],
      'activityLabels': ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
      'sessions': [
        {
          'title': 'Upper Body Strength',
          'icon': Icons.fitness_center,
          'duration': '45 min',
          'calories': '320 kcal',
          'time': 'Today',
        },
        {
          'title': 'Marathon Training',
          'icon': Icons.directions_run,
          'duration': '90 min',
          'calories': '850 kcal',
          'time': 'Last week',
        },
        {
          'title': 'CrossFit Session',
          'icon': Icons.flash_on,
          'duration': '60 min',
          'calories': '520 kcal',
          'time': '2 weeks ago',
        },
        {
          'title': 'Recovery Yoga',
          'icon': Icons.self_improvement,
          'duration': '45 min',
          'calories': '160 kcal',
          'time': 'Last month',
        },
      ],
    },
  };

  Map<String, dynamic> get currentData => periodData[periods[_selectedPeriodIndex]]!;

  void _showViewTipsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF12131A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: const Color(0xFFCDFF00),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Streak Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem(
                  '🔥',
                  'Set Reminders',
                  'Schedule daily workout reminders to stay consistent',
                ),
                SizedBox(height: 16),
                _buildTipItem(
                  '💪',
                  'Start Small',
                  'Even 10-minute workouts count towards your streak',
                ),
                SizedBox(height: 16),
                _buildTipItem(
                  '📅',
                  'Plan Ahead',
                  'Schedule your workouts for the week in advance',
                ),
                SizedBox(height: 16),
                _buildTipItem(
                  '🎯',
                  'Track Progress',
                  'Log every workout, no matter how small',
                ),
                SizedBox(height: 16),
                _buildTipItem(
                  '👥',
                  'Find Accountability',
                  'Share your streak with friends for motivation',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDFF00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Got it!',
                  style: TextStyle(
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipItem(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF8E8E93),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF12131A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.share,
                color: const Color(0xFFCDFF00),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Share Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose how you want to share your progress',
                style: TextStyle(
                  color: const Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              _shareOption(Icons.insert_drive_file, 'Share as PDF', () async {
                Navigator.pop(context);
                await _shareAsPDF();
              }),
              SizedBox(height: 12),
              _shareOption(Icons.image, 'Share as Image', () async {
                Navigator.pop(context);
                await _shareAsImage();
              }),
              SizedBox(height: 12),
              _shareOption(Icons.text_snippet, 'Share as Text', () {
                Navigator.pop(context);
                _shareAsText();
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF8E8E93)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shareOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFCDFF00)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF8E8E93),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsPDF() async {
    try {
      showLoadingSnackBar(context, 'Generating PDF...');

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fitness Progress Report',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Period: ${periods[_selectedPeriodIndex]}',
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Summary Statistics',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfStatCard('Workouts', '${currentData['workouts']}'),
                    _buildPdfStatCard('Minutes', '${currentData['minutes']}'),
                    _buildPdfStatCard('Calories', '${currentData['calories']}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('🔥 ', style: pw.TextStyle(fontSize: 24)),
                      pw.Text(
                        '${currentData['streak']}-day streak!',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Recent Sessions',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),
                ...((currentData['sessions'] as List).map((session) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 12),
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        session['title'],
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Duration: ${session['duration']} • Calories: ${session['calories']}',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Time: ${session['time']}',
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ))),
                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  'Generated by AI Fitmate',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/fitness_progress_share.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my fitness progress! 💪\n\n'
              'This ${periods[_selectedPeriodIndex].toLowerCase()}:\n'
              '• ${currentData['workouts']} workouts completed\n'
              '• ${currentData['minutes']} minutes exercised\n'
              '• ${currentData['calories']} calories burned\n'
              '• ${currentData['streak']}-day streak! 🔥',
      );

      if (mounted) {
        showAwesomeSnackBar(context, 'PDF shared successfully!', ContentType.success);
      }
    } catch (e) {
      if (mounted) {
        showAwesomeSnackBar(context, 'Error sharing PDF: $e', ContentType.failure);
      }
    }
  }

  Future<void> _shareAsImage() async {
    try {
      showLoadingSnackBar(context, 'Capturing screenshot...');

      final image = await _screenshotController.capture();

      if (image == null) {
        throw Exception('Failed to capture screenshot');
      }

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/fitness_progress_share.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My fitness progress this ${periods[_selectedPeriodIndex].toLowerCase()}! 💪🔥',
      );

      if (mounted) {
        showAwesomeSnackBar(context, 'Image shared successfully!', ContentType.success);
      }
    } catch (e) {
      if (mounted) {
        showAwesomeSnackBar(context, 'Error sharing image: $e', ContentType.failure);
      }
    }
  }

  void _shareAsText() {
    final text = '''
🏋️ My Fitness Progress - ${periods[_selectedPeriodIndex]} 🏋️

📊 Summary:
• Workouts: ${currentData['workouts']}
• Minutes: ${currentData['minutes']}
• Calories: ${currentData['calories']}
• Streak: ${currentData['streak']} days 🔥

💪 Recent Sessions:
${(currentData['sessions'] as List).map((session) => '• ${session['title']} (${session['duration']}, ${session['calories']})').join('\n')}

Keep crushing those fitness goals! 💯

Shared via AI Fitmate
    ''';

    Share.share(text, subject: 'My Fitness Progress');

    showAwesomeSnackBar(context, 'Progress shared successfully!', ContentType.success);
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF12131A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Export Progress',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _exportOption(Icons.picture_as_pdf, 'Export as PDF', _exportAsPDF),
              SizedBox(height: 12),
              _exportOption(Icons.table_chart, 'Export as CSV', _exportAsCSV),
              SizedBox(height: 12),
              _exportOption(Icons.image, 'Export as Image', _exportAsImage),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF8E8E93)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _exportOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFCDFF00)),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    try {
      // Show loading
      showLoadingSnackBar(context, "Generating PDF...");


      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fitness Progress Report',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Period: ${periods[_selectedPeriodIndex]}',
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                // Stats Summary
                pw.Text(
                  'Summary Statistics',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfStatCard('Workouts', '${currentData['workouts']}'),
                    _buildPdfStatCard('Minutes', '${currentData['minutes']}'),
                    _buildPdfStatCard('Calories', '${currentData['calories']}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('🔥 ', style: pw.TextStyle(fontSize: 24)),
                      pw.Text(
                        '${currentData['streak']}-day streak!',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Recent Sessions
                pw.Text(
                  'Recent Sessions',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),
                ...((currentData['sessions'] as List).map((session) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 12),
                  padding: pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        session['title'],
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Duration: ${session['duration']} • Calories: ${session['calories']}',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Time: ${session['time']}',
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ))),
                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  'Generated by AI Fitmate',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/fitness_progress_${periods[_selectedPeriodIndex].toLowerCase()}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'My Fitness Progress Report');

      if (mounted) {
        showAwesomeSnackBar(context, '✓ PDF exported successfully!', ContentType.success);

      }
    } catch (e) {
      if (mounted) {
        showAwesomeSnackBar(context, 'Error exporting PDF: $e', ContentType.failure);

      }
    }
  }

  pw.Widget _buildPdfStatCard(String label, String value) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsCSV() async {
    try {
      // Show loading
      showLoadingSnackBar(context, "Generating CSV...");


      List<List<dynamic>> rows = [];

      // Headers
      rows.add(['AI Fitmate - Progress Report']);
      rows.add(['Period', periods[_selectedPeriodIndex]]);
      rows.add([]);

      // Summary Stats
      rows.add(['Summary Statistics']);
      rows.add(['Metric', 'Value']);
      rows.add(['Workouts', currentData['workouts']]);
      rows.add(['Minutes', currentData['minutes']]);
      rows.add(['Minutes Goal', currentData['minutesGoal']]);
      rows.add(['Calories Burned', currentData['calories']]);
      rows.add(['Current Streak', '${currentData['streak']} days']);
      rows.add([]);

      // Activity Data
      rows.add(['Activity Data']);
      rows.add(['Label', 'Minutes']);
      final activityList = currentData['activity'] as List;
      final labelsList = currentData['activityLabels'] as List;
      for (int i = 0; i < activityList.length; i++) {
        rows.add([labelsList[i], activityList[i]]);
      }
      rows.add([]);

      // Recent Sessions
      rows.add(['Recent Sessions']);
      rows.add(['Title', 'Duration', 'Calories', 'Time']);

      for (var session in (currentData['sessions'] as List)) {
        rows.add([
          session['title'],
          session['duration'],
          session['calories'],
          session['time'],
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/fitness_progress_${periods[_selectedPeriodIndex].toLowerCase()}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'My Fitness Progress Data');

      if (mounted) {
        showAwesomeSnackBar(context, '✓ CSV exported successfully!', ContentType.success);

      }
    } catch (e) {
      if (mounted) {
        showAwesomeSnackBar(context, 'Error exporting CSV: $e', ContentType.failure);

      }
    }
  }

  Future<void> _exportAsImage() async {
    try {
      // Show loading
      showLoadingSnackBar(context, "Capturing Screenshot...");


      final image = await _screenshotController.capture();

      if (image == null) {
        throw Exception('Failed to capture screenshot');
      }

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/fitness_progress_${periods[_selectedPeriodIndex].toLowerCase()}.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles([XFile(file.path)], text: 'My Fitness Progress');

      if (mounted) {
        showAwesomeSnackBar(context, '✓ Image exported successfully!', ContentType.success);

      }
    } catch (e) {
      if (mounted) {
        showAwesomeSnackBar(context, 'Error exporting image: $e', ContentType.failure);

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: const Color(0xFF000000),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),
                _buildHeader(width, height),
                SizedBox(height: height * 0.025),
                _buildPeriodSelector(width, height),
                SizedBox(height: height * 0.025),
                _buildStatsCards(width, height),
                SizedBox(height: height * 0.025),
                _buildWeeklyActivityChart(width, height),
                SizedBox(height: height * 0.025),
                _buildStreakCard(width, height),
                SizedBox(height: height * 0.025),
                _buildRecentSessions(width, height),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: width * 0.08,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
          Row(
          children: [
            GestureDetector(
              onTap: _showExportDialog,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.012,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDFF00),
                  borderRadius: BorderRadius.circular(width * 0.06),
                ),
                child: Text(
                  'Export',
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.03),
            GestureDetector(
              onTap: _showShareDialog,
              child: Icon(
                Icons.share,
                color: Colors.white,
                size: width * 0.065,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.015),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.08),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(
          periods.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriodIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.015),
                decoration: BoxDecoration(
                  color: _selectedPeriodIndex == index
                      ? const Color(0xFF1B1D26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(width * 0.07),
                ),
                child: Text(
                  periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.042,
                    fontWeight: _selectedPeriodIndex == index
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _selectedPeriodIndex == index
                        ? const Color(0xFFCDFF00)
                        : const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Workouts',
            '${currentData['workouts']}',
            'This ${periods[_selectedPeriodIndex].toLowerCase()}',
            width,
            height,
          ),
          _buildDivider(height),
          _buildStatItem(
            'Minutes',
            '${currentData['minutes']}',
            'Goal ${currentData['minutesGoal']}',
            width,
            height,
          ),
          _buildDivider(height),
          _buildStatItem(
            'Calories',
            '${currentData['calories']}',
            'Burned',
            width,
            height,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String subtitle,
    double width,
    double height,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
          SizedBox(height: height * 0.01),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: width * 0.08,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: height * 0.005),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: width * 0.035,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double height) {
    return Container(
      height: height * 0.08,
      width: 1,
      color: const Color(0xFF2C2C2E),
    );
  }

  Widget _buildWeeklyActivityChart(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${periods[_selectedPeriodIndex]}ly Activity',
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: height * 0.03),
          SizedBox(
            height: height * 0.25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                (currentData['activity'] as List).length,
                (index) => _buildActivityBar(
                  (currentData['activity'] as List)[index].toDouble(),
                  (currentData['activityLabels'] as List)[index],
                  width,
                  height,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(
    double minutes,
    String day,
    double width,
    double height,
  ) {
    // Calculate max based on period
    final List<int> activityList = List<int>.from(currentData['activity']);
    final double maxMinutes = activityList.reduce((a, b) => a > b ? a : b).toDouble();
    final barHeight = maxMinutes > 0 ? (minutes / maxMinutes) * height * 0.2 : height * 0.02;

    // Dynamic width based on number of bars
    final barCount = activityList.length;
    final barWidth = barCount > 7 ? width * 0.055 : width * 0.08;
    final fontSize = barCount > 7 ? width * 0.028 : width * 0.035;

    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: barWidth,
            height: barHeight < height * 0.02 ? height * 0.02 : barHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF00FF87), // Bright mint green
                  const Color(0xFF00C853), // Deep green
                ],
              ),
              borderRadius: BorderRadius.circular(width * 0.02),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.008),
          Text(
            day,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(
          color: const Color(0xFF212229),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: const Color(0xFFCDFF00),
            size: width * 0.1,
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentData['streak']}-day streak',
                  style: TextStyle(
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFCDFF00),
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  'Keep going to beat your record',
                  style: TextStyle(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: width * 0.03),
          GestureDetector(
            onTap: _showViewTipsDialog,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.012,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFCDFF00),
                borderRadius: BorderRadius.circular(width * 0.06),
              ),
              child: Text(
                'View Tips',
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: height * 0.015),
        ...(currentData['sessions'] as List<Map<String, dynamic>>).map(
          (session) => _buildSessionCard(session, width, height),
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    Map<String, dynamic> session,
    double width,
    double height,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF101118),
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Icon(
              session['icon'],
              color: const Color(0xFFCDFF00),
              size: width * 0.065,
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title'],
                  style: TextStyle(
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  '${session['duration']} • ${session['calories']}',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Text(
            session['time'],
            style: TextStyle(
              fontSize: width * 0.035,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

