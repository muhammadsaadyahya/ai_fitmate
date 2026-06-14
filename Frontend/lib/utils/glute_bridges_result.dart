import 'package:flutter/material.dart';

class GluteBridgesAnalysisResult {
  final int reps;
  final String state;
  final String statusMessage;
  final Color statusColor;
  final double bridgeAngle;
  final double kneeAngle;
  final bool isBadForm;

  GluteBridgesAnalysisResult({
    required this.reps,
    required this.state,
    required this.statusMessage,
    required this.statusColor,
    required this.bridgeAngle,
    required this.kneeAngle,
    required this.isBadForm,
  });
}
