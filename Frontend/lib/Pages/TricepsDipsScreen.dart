import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../utils/triceps_dips_analyzer.dart';

class TricepsDipsScreen extends StatefulWidget {
  const TricepsDipsScreen({super.key});

  @override
  State<TricepsDipsScreen> createState() => _TricepsDipsScreenState();
}

class _TricepsDipsScreenState extends State<TricepsDipsScreen> {
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
  final TricepsDipsAnalyzer _analyzer = TricepsDipsAnalyzer();
  late final FlutterTts _flutterTts;
  DateTime? _lastSpeechTime;
  String? _lastSpokenText;
  static const int _speechCooldownMs = 2500;

  late ValueNotifier<int> _repsNotifier;
  late ValueNotifier<String> _statusNotifier;
  late ValueNotifier<Color> _statusColorNotifier;
  late ValueNotifier<double> _angleNotifier;

  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape (horizontal)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _repsNotifier = ValueNotifier(0);
    _statusNotifier = ValueNotifier('Initializing...');
    _statusColorNotifier = ValueNotifier(Colors.white);
    _angleNotifier = ValueNotifier(0.0);

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
        text.startsWith('Lower') && !text.contains('Go')) {
      return;
    }

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
      if (_cameras!.isEmpty) {
        _updateStatus('No camera found', Colors.red);
        return;
      }

      final frontCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      _isInitialized = true;
      _controller!.startImageStream(_processImage);

      setState(() {});
      _updateStatus('Camera ready', Colors.green);
    } catch (e) {
      _updateStatus('Camera error', Colors.red);
    }
  }

  void _updateStatus(String status, Color color) {
    _statusNotifier.value = status;
    _statusColorNotifier.value = color;
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final rotation = _getImageRotation(image);
      _currentImageWidth = image.width;
      _currentImageHeight = image.height;
      _currentImageRotation = rotation;
      _currentLensDirection = _controller!.description.lensDirection;

      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        _updateStatus('No pose detected', Colors.orange);
        _isDetecting = false;
        return;
      }

      final pose = poses.first;
      _processPose(pose, image.width, image.height);
    } finally {
      _isDetecting = false;
    }
  }

  void _processPose(Pose pose, int imgWidth, int imgHeight) {
    _currentPose = pose;
    final lm = pose.landmarks;

    final requiredLandmarks = [
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    ];

    bool allVisible = true;
    for (var type in requiredLandmarks) {
      if (lm[type] == null || lm[type]!.likelihood < _minLandmarkConfidence) {
        allVisible = false;
        break;
      }
    }

    if (!allVisible) {
      _updateStatus('Move fully into frame', Colors.orange);
      return;
    }

    final double leftVis =
        [
          PoseLandmarkType.leftEar,
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftElbow,
          PoseLandmarkType.leftWrist,
          PoseLandmarkType.leftHip,
        ].fold<double>(
          1.0,
          (acc, type) =>
              (acc < lm[type]!.likelihood) ? acc : lm[type]!.likelihood,
        );

    final double rightVis =
        [
          PoseLandmarkType.rightEar,
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightElbow,
          PoseLandmarkType.rightWrist,
          PoseLandmarkType.rightHip,
        ].fold<double>(
          1.0,
          (acc, type) =>
              (acc < lm[type]!.likelihood) ? acc : lm[type]!.likelihood,
        );

    final side = rightVis > leftVis ? 'right' : 'left';

    final ear = _getLandmarkPoint(
      lm,
      side == 'right' ? PoseLandmarkType.rightEar : PoseLandmarkType.leftEar,
      imgWidth,
      imgHeight,
    );
    final shoulder = _getLandmarkPoint(
      lm,
      side == 'right'
          ? PoseLandmarkType.rightShoulder
          : PoseLandmarkType.leftShoulder,
      imgWidth,
      imgHeight,
    );
    final elbow = _getLandmarkPoint(
      lm,
      side == 'right'
          ? PoseLandmarkType.rightElbow
          : PoseLandmarkType.leftElbow,
      imgWidth,
      imgHeight,
    );
    final wrist = _getLandmarkPoint(
      lm,
      side == 'right'
          ? PoseLandmarkType.rightWrist
          : PoseLandmarkType.leftWrist,
      imgWidth,
      imgHeight,
    );
    final hip = _getLandmarkPoint(
      lm,
      side == 'right' ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip,
      imgWidth,
      imgHeight,
    );

    final shoulderElbowWristAngle = TricepsDipsAnalyzer.calculateAngle(
      shoulder,
      elbow,
      wrist,
    );
    final neckDist = TricepsDipsAnalyzer.euclideanDist(ear, shoulder);
    final torsoAngle = TricepsDipsAnalyzer.calculateAngle(shoulder, hip, [
      hip[0],
      hip[1] - 100.0,
    ]);
    final hipWristXDist = (hip[0] - wrist[0]).abs();
    final shoulderHipDist = TricepsDipsAnalyzer.euclideanDist(shoulder, hip);

    final result = _analyzer.analyze(
      shoulderElbowWristAngle: shoulderElbowWristAngle,
      neckDist: neckDist,
      torsoAngle: torsoAngle,
      hipWristXDist: hipWristXDist,
      shoulderHipDist: shoulderHipDist,
    );

    if (result.isBadForm ||
        result.statusMessage.contains('deep') ||
        result.statusMessage.contains('shrug') ||
        result.statusMessage.contains('bench') ||
        result.statusMessage.contains('lower') ||
        result.statusMessage.contains('Lock')) {
      _speak(result.statusMessage);
    }

    _repsNotifier.value = result.reps;
    _updateStatus(result.statusMessage, result.statusColor);
    _angleNotifier.value = result.elbowAngle;
  }

  List<double> _getLandmarkPoint(
    Map<PoseLandmarkType, PoseLandmark> lm,
    PoseLandmarkType type,
    int w,
    int h,
  ) {
    if (lm[type] == null) return [0.0, 0.0];
    return [lm[type]!.x * w.toDouble(), lm[type]!.y * h.toDouble()];
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _controller == null) return;
    if (_isSwitchingCamera) return;
    _isSwitchingCamera = true;
    if (mounted) setState(() {});
    final current = _controller!.description;
    final next = _cameras!.firstWhere(
      (c) => c.lensDirection != current.lensDirection,
      orElse: () => _cameras!.first,
    );
    await _controller?.dispose();
    _controller = CameraController(
      next,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _controller?.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await _controller?.initialize();
      await _controller?.startImageStream(_processImage);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Failed to switch camera.')),
      );
    }
    _isSwitchingCamera = false;
    if (mounted) setState(() {});
  }

  InputImage? _buildInputImage(CameraImage image) {
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

  InputImageRotation? _getImageRotation(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final rotationMap = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
      final rotationCompensation =
          rotationMap[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      return InputImageRotationValue.fromRawValue(
        (sensorOrientation + rotationCompensation) % 360,
      );
    }
    return null;
  }

  @override
  void dispose() {
    _poseDetector.close();
    // Restore orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller?.dispose();
    _repsNotifier.dispose();
    _statusNotifier.dispose();
    _statusColorNotifier.dispose();
    _angleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

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
                                  statusColor: _statusColorNotifier.value,
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
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(width * 0.04),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AI Fitness Trainer - Triceps Dips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: width * 0.08,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(width * 0.05),
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'REPS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ValueListenableBuilder<int>(
                                  valueListenable: _repsNotifier,
                                  builder: (_, reps, __) {
                                    return Text(
                                      '$reps',
                                      style: TextStyle(
                                        color: Color(0xFFCDFF00),
                                        fontSize: width * 0.08,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                ValueListenableBuilder<String>(
                                  valueListenable: _statusNotifier,
                                  builder: (_, status, __) {
                                    return Text(
                                      status,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: width * 0.045,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: width * 0.08,
                              ),
                              onPressed: _toggleCamera,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final leftHip = getOffset(PoseLandmarkType.leftHip);
    final rightHip = getOffset(PoseLandmarkType.rightHip);
    final leftKnee = getOffset(PoseLandmarkType.leftKnee);
    final rightKnee = getOffset(PoseLandmarkType.rightKnee);
    final leftAnkle = getOffset(PoseLandmarkType.leftAnkle);
    final rightAnkle = getOffset(PoseLandmarkType.rightAnkle);

    void drawSafeLine(Offset? p1, Offset? p2) {
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }

    drawSafeLine(leftShoulder, rightShoulder);
    drawSafeLine(leftHip, rightHip);
    drawSafeLine(leftShoulder, leftHip);
    drawSafeLine(rightShoulder, rightHip);

    drawSafeLine(leftShoulder, leftElbow);
    drawSafeLine(leftElbow, leftWrist);
    drawSafeLine(leftHip, leftKnee);
    drawSafeLine(leftKnee, leftAnkle);

    drawSafeLine(rightShoulder, rightElbow);
    drawSafeLine(rightElbow, rightWrist);
    drawSafeLine(rightHip, rightKnee);
    drawSafeLine(rightKnee, rightAnkle);

    final allJoints = [
      leftShoulder,
      rightShoulder,
      leftElbow,
      rightElbow,
      leftWrist,
      rightWrist,
      leftHip,
      rightHip,
      leftKnee,
      rightKnee,
      leftAnkle,
      rightAnkle,
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
