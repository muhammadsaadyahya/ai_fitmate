import 'package:flutter/material.dart';

class CrunchesAnalysisResult {
  final int reps;
  final String state;
  final String statusMessage;
  final Color statusColor;
  final double crunchAngle;
  final double neckDist;
  final bool isBadForm;

  CrunchesAnalysisResult({
    required this.reps,
    required this.state,
    required this.statusMessage,
    required this.statusColor,
    required this.crunchAngle,
    required this.neckDist,
    required this.isBadForm,
  });
}
