import 'package:flutter/material.dart';

class TricepsDipsAnalysisResult {
  final int reps;
  final String state;
  final String statusMessage;
  final Color statusColor;
  final double elbowAngle;
  final bool isBadForm;

  TricepsDipsAnalysisResult({
    required this.reps,
    required this.state,
    required this.statusMessage,
    required this.statusColor,
    required this.elbowAngle,
    required this.isBadForm,
  });
}
