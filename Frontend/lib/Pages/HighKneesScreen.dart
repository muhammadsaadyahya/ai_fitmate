import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/pose_math.dart';
import '../utils/high_knees_analyzer.dart';

class HighKneesScreen extends StatefulWidget {
  const HighKneesScreen({super.key});

  @override
  State<HighKneesScreen> createState() => _HighKneesScreenState();
}

class _HighKneesScreenState extends State<HighKneesScreen> {
  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isSwitchingCamera = false;

  late final PoseDetector _poseDetector;
  final HighKneesAnalyzer _analyzer = HighKneesAnalyzer();
  late final FlutterTts _flutterTts;
  DateTime? _lastSpeechTime;
  static const int _speechCooldownMs = 2000;

  bool _isDetecting = false;

  Pose? _currentPose;
  Size? _currentImageSize;
  InputImageRotation? _currentImageRotation;

  HighKneesAnalysisResult? _latest;
  String _fallbackStatus = 'Point the camera at your side';
  Color _fallbackColor = Colors.white;

  double? _smoothLeftAngle;
  double? _smoothRightAngle;

  void _speak(String text) async {
    final now = DateTime.now();
    if (_lastSpeechTime == null ||
        now.difference(_lastSpeechTime!).inMilliseconds > _speechCooldownMs) {
      _lastSpeechTime = now;
      await _flutterTts.speak(text);
    }
  }

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

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

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
          content: Text(
            'Camera permission required. Please enable in settings.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _controller == null) return;
    if (_isSwitchingCamera) return; // Prevent concurrent camera switches

    _isSwitchingCamera = true;
    if (mounted) {
      setState(() {});
    }

    final current = _controller!.description;
    final next = _cameras!.firstWhere(
      (c) => c.lensDirection != current.lensDirection,
      orElse: () => _cameras!.first,
    );

    _analyzer.reset();
    _latest = null;
    _currentPose = null;
    _currentImageSize = null;
    _currentImageRotation = null;
    _fallbackStatus = 'Point the camera at your side';
    _fallbackColor = Colors.white;

    _smoothLeftAngle = null;
    _smoothRightAngle = null;

    final oldController = _controller;
    _controller = null;

    await oldController!.stopImageStream();
    await oldController.dispose();

    _controller = CameraController(
      next,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);

    _isSwitchingCamera = false;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _controller == null) return;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      if (mounted && _fallbackStatus != 'Unsupported camera format') {
        setState(() {
          _currentPose = null;
          _latest = null;
          _fallbackStatus = 'Unsupported camera format';
          _fallbackColor = Colors.white;
        });
      }
      return;
    }

    _isDetecting = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (!mounted) return;

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final computed = _computeHighKnees(pose);
        if (computed != null) {
          final result = _analyzer.analyze(
            leftAngle: computed.leftAngle,
            rightAngle: computed.rightAngle,
            leftKneeBend3D: computed.leftKneeBend3D,
            rightKneeBend3D: computed.rightKneeBend3D,
            torsoLateralLean: computed.torsoLateralLean,
            torsoBackwardLeanZ: computed.torsoBackwardLeanZ,
            onSpeak: _speak,
          );

          setState(() {
            _currentPose = pose;
            _latest = result;
            _fallbackStatus = result.status;
            _fallbackColor = result.color;
          });
        } else {
          setState(() {
            _currentPose = pose;
            _latest = null;
            _fallbackStatus = 'Move full body into frame';
            _fallbackColor = Colors.white;
          });
        }
      } else {
        setState(() {
          _currentPose = null;
          _latest = null;
          _fallbackStatus = 'No pose detected';
          _fallbackColor = Colors.white;
        });
      }
    } catch (e) {
      debugPrint('Pose detection error: $e');
      if (mounted) {
        setState(() {
          _currentPose = null;
          _latest = null;
          _fallbackStatus = 'Pose detection error';
          _fallbackColor = Colors.white;
        });
      }
    } finally {
      _isDetecting = false;
    }
  }

  _HighKneesMetrics? _computeHighKnees(Pose pose) {
    final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (lSh == null ||
        lHip == null ||
        lKnee == null ||
        lAnkle == null ||
        rSh == null ||
        rHip == null ||
        rKnee == null ||
        rAnkle == null) {
      return null;
    }

    if (lSh.likelihood < 0.5 ||
        lHip.likelihood < 0.5 ||
        lKnee.likelihood < 0.5 ||
        rSh.likelihood < 0.5 ||
        rHip.likelihood < 0.5 ||
        rKnee.likelihood < 0.5) {
      return null;
    }

    final lShPt = Offset(lSh.x, lSh.y);
    final lHipPt = Offset(lHip.x, lHip.y);
    final lKneePt = Offset(lKnee.x, lKnee.y);

    final rShPt = Offset(rSh.x, rSh.y);
    final rHipPt = Offset(rHip.x, rHip.y);
    final rKneePt = Offset(rKnee.x, rKnee.y);

    double rawLeftAngle = PoseMath.calculateAngle(lShPt, lHipPt, lKneePt);
    double rawRightAngle = PoseMath.calculateAngle(rShPt, rHipPt, rKneePt);

    final double alpha = 0.4;
    _smoothLeftAngle = _smoothLeftAngle != null
        ? (alpha * rawLeftAngle + (1 - alpha) * _smoothLeftAngle!)
        : rawLeftAngle;
    _smoothRightAngle = _smoothRightAngle != null
        ? (alpha * rawRightAngle + (1 - alpha) * _smoothRightAngle!)
        : rawRightAngle;

    final leftKneeBend3D = PoseMath.calculateAngle3D(
      lHip.x,
      lHip.y,
      lHip.z,
      lKnee.x,
      lKnee.y,
      lKnee.z,
      lAnkle.x,
      lAnkle.y,
      lAnkle.z,
    );
    final rightKneeBend3D = PoseMath.calculateAngle3D(
      rHip.x,
      rHip.y,
      rHip.z,
      rKnee.x,
      rKnee.y,
      rKnee.z,
      rAnkle.x,
      rAnkle.y,
      rAnkle.z,
    );

    final midShPt = Offset((lSh.x + rSh.x) / 2, (lSh.y + rSh.y) / 2);
    final midHipPt = Offset((lHip.x + rHip.x) / 2, (lHip.y + rHip.y) / 2);
    final torsoLateralLean = PoseMath.calculateAngle(
      midShPt,
      midHipPt,
      Offset(midHipPt.dx, 0),
    );

    final midShZ = (lSh.z + rSh.z) / 2.0;
    final midHipZ = (lHip.z + rHip.z) / 2.0;

    final torsoBackwardLeanZ = midShZ - midHipZ;

    return _HighKneesMetrics(
      leftAngle: _smoothLeftAngle!,
      rightAngle: _smoothRightAngle!,
      leftKneeBend3D: leftKneeBend3D,
      rightKneeBend3D: rightKneeBend3D,
      torsoLateralLean: torsoLateralLean,
      torsoBackwardLeanZ: torsoBackwardLeanZ,
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
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
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    _currentImageRotation = rotation;
    _currentImageSize = Size(image.width.toDouble(), image.height.toDouble());

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
    final oldController = _controller;
    _controller = null;
    try {
      oldController?.stopImageStream();
    } catch (_) {}
    oldController?.dispose();
    _poseDetector.close();
    // Restore orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final status = _latest?.status ?? _fallbackStatus;
    final color = _latest?.color ?? _fallbackColor;
    final reps = _latest?.reps ?? _analyzer.reps;
    final stage = _latest?.stage ?? 'Down';
    final streak = _latest?.streak ?? _analyzer.streak;
    final maxStreak = _latest?.maxStreak ?? _analyzer.maxStreak;

    final activeAngle = _latest?.activeAngle ?? 180;
    final progress = (1.0 - ((activeAngle - 90) / (170 - 90))).clamp(0.0, 1.0);

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
                            if (_currentPose != null &&
                                _currentImageSize != null &&
                                _currentImageRotation != null)
                              CustomPaint(
                                painter: PosePainter(
                                  pose: _currentPose!,
                                  statusColor: color,
                                  imageSize: _currentImageSize!,
                                  rotation: _currentImageRotation!,
                                  lensDirection:
                                      _controller!.description.lensDirection,
                                  leftAngle: _latest?.leftAngle,
                                  rightAngle: _latest?.rightAngle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 20,
                    top: MediaQuery.of(context).size.height * 0.3,
                    child: Container(
                      width: 20,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 20,
                          height: 200 * progress,
                          decoration: BoxDecoration(
                            color: progress < 0.8 ? Colors.amber : Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                            'AI Fitness Trainer - High Knees',
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
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text(
                                      'REPS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$reps',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text(
                                      'STREAK: ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '$streak',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Max: $maxStreak',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Stage: $stage',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  status,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_cameras != null && _cameras!.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: width * 0.08,
                              ),
                              onPressed: _toggleCamera,
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

class _HighKneesMetrics {
  const _HighKneesMetrics({
    required this.leftAngle,
    required this.rightAngle,
    required this.leftKneeBend3D,
    required this.rightKneeBend3D,
    required this.torsoLateralLean,
    required this.torsoBackwardLeanZ,
  });

  final double leftAngle;
  final double rightAngle;
  final double leftKneeBend3D;
  final double rightKneeBend3D;
  final double torsoLateralLean;
  final double torsoBackwardLeanZ;
}

class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    required this.statusColor,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
    this.leftAngle,
    this.rightAngle,
  });

  final Pose pose;
  final Color statusColor;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;
  final double? leftAngle;
  final double? rightAngle;

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
    drawSafeLine(leftHip, leftKnee);
    drawSafeLine(leftKnee, leftAnkle);
    drawSafeLine(rightHip, rightKnee);
    drawSafeLine(rightKnee, rightAnkle);

    final allJoints = [
      leftShoulder,
      rightShoulder,
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

    void drawAngle(double? angle, Offset? offset) {
      if (angle == null || offset == null) return;
      final textSpan = TextSpan(
        text: angle.toStringAsFixed(0),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 4),
            Shadow(color: Colors.black, offset: Offset(-1, -1), blurRadius: 4),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx + 15, offset.dy - 10));
    }

    drawAngle(leftAngle, leftHip);
    drawAngle(rightAngle, rightHip);
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
