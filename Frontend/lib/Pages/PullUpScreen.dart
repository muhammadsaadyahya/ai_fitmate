import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/pull_up_analyzer.dart';
import '../utils/pull_up_result.dart';
import '../utils/pose_math.dart';

class PullUpScreen extends StatefulWidget {
  const PullUpScreen({super.key});

  @override
  State<PullUpScreen> createState() => _PullUpScreenState();
}

class _PoseRenderData {
  final Pose pose;
  final Size imageSize;
  final InputImageRotation rotation;

  _PoseRenderData(this.pose, this.imageSize, this.rotation);
}

class _PullUpScreenState extends State<PullUpScreen> {
  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  static const double _minLandmarkConfidence = 0.5;

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isSwitchingCamera = false;
  bool _isDetecting = false;

  Pose? _currentPose;
  InputImageRotation? _currentImageRotation;
  int? _currentImageWidth;
  int? _currentImageHeight;
  late CameraLensDirection _currentLensDirection;

  late final PoseDetector _poseDetector;
  final PullUpAnalyzer _analyzer = PullUpAnalyzer();
  late final FlutterTts _flutterTts;
  DateTime? _lastSpeechTime;
  String? _lastSpokenText;
  static const int _speechCooldownMs = 2500;

  // Notifiers to prevent setState spam
  final ValueNotifier<PullUpAnalysisResult?> _resultNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<_PoseRenderData?> _poseNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape (horizontal)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
    _flutterTts = FlutterTts();
    _initTts();
    _initializeCamera();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(false);
  }

  void _speak(String text) async {
    if (text.isEmpty ||
        text == 'Waiting...' ||
        text == 'Top reached' ||
        text == 'Rep counted')
      return;

    final now = DateTime.now();
    if (_lastSpokenText == text &&
        _lastSpeechTime != null &&
        now.difference(_lastSpeechTime!).inMilliseconds <
            _speechCooldownMs * 2) {
      return;
    }

    if (_lastSpeechTime == null ||
        now.difference(_lastSpeechTime!).inMilliseconds > _speechCooldownMs) {
      _lastSpeechTime = now;
      _lastSpokenText = text;
      await _flutterTts.speak(text);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });

      await _controller!.startImageStream(_processCameraImage);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Camera permission required.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting ||
        _controller == null ||
        !_controller!.value.isInitialized)
      return;

    final rotation = _getImageRotation(image);
    _currentImageWidth = image.width;
    _currentImageHeight = image.height;
    _currentImageRotation = rotation;
    _currentLensDirection = _controller!.description.lensDirection;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _isDetecting = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (!mounted) return;

      if (poses.isNotEmpty) {
        final pose = poses.first;
        _currentPose = pose;
        if (rotation != null) {
          // Keep existing _poseNotifier for other uses
        }

        _processPoseTracking(pose);
      }
    } catch (e) {
      debugPrint('Pose detection error: $e');
    } finally {
      if (mounted) {
        _isDetecting = false;
      }
    }
  }

  void _processPoseTracking(Pose pose) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final nose = pose.landmarks[PoseLandmarkType.nose];
    final ls = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rs = pose.landmarks[PoseLandmarkType.rightShoulder];
    final le = pose.landmarks[PoseLandmarkType.leftElbow];
    final re = pose.landmarks[PoseLandmarkType.rightElbow];
    final lw = pose.landmarks[PoseLandmarkType.leftWrist];
    final rw = pose.landmarks[PoseLandmarkType.rightWrist];
    final lh = pose.landmarks[PoseLandmarkType.leftHip];
    final rh = pose.landmarks[PoseLandmarkType.rightHip];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final requiredLandmarks = [ls, rs, le, re, lw, rw, lh, rh, lAnkle, rAnkle];

    if (requiredLandmarks.any(
      (lm) => lm == null || lm.likelihood < _minLandmarkConfidence,
    )) {
      return;
    }

    // Convert to Offsets
    final nosePt = Offset(nose?.x ?? 0, nose?.y ?? 0);
    final lsPt = Offset(ls!.x, ls.y);
    final rsPt = Offset(rs!.x, rs.y);
    final lePt = Offset(le!.x, le.y);
    final rePt = Offset(re!.x, re.y);
    final lwPt = Offset(lw!.x, lw.y);
    final rwPt = Offset(rw!.x, rw.y);
    final lhPt = Offset(lh!.x, lh.y);
    final rhPt = Offset(rh!.x, rh.y);
    final lAnklePt = Offset(lAnkle!.x, lAnkle.y);
    final rAnklePt = Offset(rAnkle!.x, rAnkle.y);

    // Midpoints
    final midShoulder = _mid(lsPt, rsPt);
    final midHip = _mid(lhPt, rhPt);
    final midAnkle = _mid(lAnklePt, rAnklePt);

    // Angles
    final lElbowAngle = PoseMath.calculateAngle(lsPt, lePt, lwPt);
    final rElbowAngle = PoseMath.calculateAngle(rsPt, rePt, rwPt);
    final hipAngle = PoseMath.calculateAngle(midShoulder, midHip, midAnkle);

    // Body length & Ankle X
    final bodyLength = (midShoulder - midAnkle).distance;
    final midAnkleX = midAnkle.dx;

    final result = _analyzer.analyze(
      rawLeftElbow: lElbowAngle,
      rawRightElbow: rElbowAngle,
      rawHipAngle: hipAngle,
      midAnkleX: midAnkleX,
      bodyLength: bodyLength,
      noseY: nosePt.dy,
      leftWristY: lwPt.dy,
      rightWristY: rwPt.dy,
      noseVisible: nose != null && nose.likelihood >= _minLandmarkConfidence,
    );

    if (result.isBadForm ||
        result.statusMessage.contains('Extend') ||
        result.statusMessage.contains('chin over')) {
      _speak(result.statusMessage);
    }

    _resultNotifier.value = result;
  }

  Offset _mid(Offset a, Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  InputImageRotation? _getImageRotation(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      return InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    return null;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final rotation = _getImageRotation(image);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector.close();
    _resultNotifier.dispose();
    _poseNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isInitialized && _controller != null && !_isSwitchingCamera
            ? Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: size.width,
                        height: size.width / _controller!.value.aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(_controller!),
                            if (_currentPose != null)
                              CustomPaint(
                                painter: PosePainter(
                                  pose: _currentPose!,
                                  statusColor: Colors.white,
                                  imageSize: Size(
                                    _currentImageWidth?.toDouble() ?? 0,
                                    _currentImageHeight?.toDouble() ?? 0,
                                  ),
                                  rotation:
                                      _currentImageRotation ??
                                      InputImageRotation.rotation0deg,
                                  lensDirection: _currentLensDirection,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<PullUpAnalysisResult?>(
                    valueListenable: _resultNotifier,
                    builder: (context, result, child) {
                      if (result == null) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'REPS: ${result.reps}',
                                style: TextStyle(
                                  color: result.statusColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'STATE: ${result.state}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'ELBOW AVG: ${result.elbowAvg.toInt()}°',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.statusMessage,
                                style: TextStyle(
                                  color: result.statusColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Color(0xFFCDFF00)),
              ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    required this.statusColor,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
  });

  final Pose pose;
  final Color statusColor;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = statusColor;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    double translateX(double x) {
      final double scaled;
      switch (rotation) {
        case InputImageRotation.rotation90deg:
        case InputImageRotation.rotation270deg:
          scaled = x * size.width / imageSize.height;
          break;
        case InputImageRotation.rotation0deg:
        case InputImageRotation.rotation180deg:
          scaled = x * size.width / imageSize.width;
          break;
      }
      if (lensDirection == CameraLensDirection.front) {
        return size.width - scaled;
      }
      return scaled;
    }

    double translateY(double y) {
      switch (rotation) {
        case InputImageRotation.rotation90deg:
        case InputImageRotation.rotation270deg:
          return y * size.height / imageSize.width;
        case InputImageRotation.rotation0deg:
        case InputImageRotation.rotation180deg:
          return y * size.height / imageSize.height;
      }
    }

    Offset? getOffset(PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm == null) return null;
      return Offset(translateX(lm.x), translateY(lm.y));
    }

    final leftShoulder = getOffset(PoseLandmarkType.leftShoulder);
    final rightShoulder = getOffset(PoseLandmarkType.rightShoulder);
    final leftElbow = getOffset(PoseLandmarkType.leftElbow);
    final rightElbow = getOffset(PoseLandmarkType.rightElbow);
    final leftWrist = getOffset(PoseLandmarkType.leftWrist);
    final rightWrist = getOffset(PoseLandmarkType.rightWrist);

    void drawSafeLine(Offset? p1, Offset? p2) {
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }

    drawSafeLine(leftShoulder, rightShoulder);
    drawSafeLine(leftShoulder, leftElbow);
    drawSafeLine(leftElbow, leftWrist);
    drawSafeLine(rightShoulder, rightElbow);
    drawSafeLine(rightElbow, rightWrist);

    final allJoints = [
      leftShoulder,
      rightShoulder,
      leftElbow,
      rightElbow,
      leftWrist,
      rightWrist,
    ];

    for (final pt in allJoints) {
      if (pt != null) {
        canvas.drawCircle(pt, 6.0, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.statusColor != statusColor ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.rotation != rotation ||
        oldDelegate.lensDirection != lensDirection;
  }
}
