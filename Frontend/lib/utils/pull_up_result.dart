import 'package:flutter/material.dart';

class PullUpAnalysisResult {
  const PullUpAnalysisResult({
    required this.reps,
    required this.state,
    required this.statusMessage,
    required this.statusColor,
    required this.elbowAvg,
    required this.isBadForm,
  });

  final int reps;
  final String state;
  final String statusMessage;
  final Color statusColor;
  final double elbowAvg;
  final bool isBadForm;
}
