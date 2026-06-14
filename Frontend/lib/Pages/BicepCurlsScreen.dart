import 'dart:io';


import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/bicep_curl_analyzer.dart';
import '../utils/pose_math.dart';


class BicepCurlsScreen extends StatefulWidget {
  const BicepCurlsScreen({super.key});

  @override
  State<BicepCurlsScreen> createState() => _BicepCurlsScreenState();
}

class _BicepCurlsScreenState extends State<BicepCurlsScreen> {
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
  final BicepCurlAnalyzer _bicepCurlAnalyzer = BicepCurlAnalyzer();
  late final FlutterTts _flutterTts;
  DateTime? _lastSpeechTime;
  static const int _speechCooldownMs = 2500;

  bool _isDetecting = false;
  DateTime? _lastFrameTs;

  Pose? _currentPose;
  Size? _currentImageSize;
  InputImageRotation? _currentImageRotation;

  BicepCurlAnalysisResult? _latest;
  String _fallbackStatus = 'Point the camera at your side';
  Color _fallbackColor = Colors.white;

  double? _lastElbowX;
  bool _useLeft = false; // Hardcoded to use right side only

  double? _smoothElbowAngle;
  int _jitterDrops = 0;

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

    _bicepCurlAnalyzer.reset();
    _latest = null;
    _lastFrameTs = null;
    _currentPose = null;
    _currentImageSize = null;
    _currentImageRotation = null;
    _fallbackStatus = 'Point the camera at your side';
    _fallbackColor = Colors.white;

    _lastElbowX = null;
    _smoothElbowAngle = null;
    _jitterDrops = 0;

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

    final now = DateTime.now();
    _lastFrameTs ??= now;

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
      _lastFrameTs = now;
      return;
    }

    _isDetecting = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (!mounted) return;

      _lastFrameTs = now;

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final computed = _computeBicepCurls(pose, image.width, image.height);
        if (computed != null) {
          final result = _bicepCurlAnalyzer.analyze(
            elbowAngle: computed.elbowAngle,
            badForm: computed.badForm,
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
            _fallbackStatus = 'Move full body into frame or Bad Pose';
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

  _BicepCurlMetrics? _computeBicepCurls(Pose pose, int w, int h) {
    // Hardcode _useLeft to false to only use the right side
    _useLeft = false;
    final useLeft = _useLeft;

    final shoulder = useLeft
        ? pose.landmarks[PoseLandmarkType.leftShoulder]
        : pose.landmarks[PoseLandmarkType.rightShoulder];
    final elbow = useLeft
        ? pose.landmarks[PoseLandmarkType.leftElbow]
        : pose.landmarks[PoseLandmarkType.rightElbow];
    final wrist = useLeft
        ? pose.landmarks[PoseLandmarkType.leftWrist]
        : pose.landmarks[PoseLandmarkType.rightWrist];
    final hip = useLeft
        ? pose.landmarks[PoseLandmarkType.leftHip]
        : pose.landmarks[PoseLandmarkType.rightHip];

    if (shoulder == null || elbow == null || wrist == null || hip == null) {
      return null;
    }

    if (shoulder.likelihood < 0.6 ||
        elbow.likelihood < 0.6 ||
        wrist.likelihood < 0.6 ||
        hip.likelihood < 0.6) {
      return null;
    }

    // Distance checks
    final dist =
        (Offset(shoulder.x * w, shoulder.y * h) - Offset(hip.x * w, hip.y * h))
            .distance;
    final tooClose = dist < 90;
    final tooFar = dist > 260;

    if (tooClose) {
      // _speak("Move back");
      // return null;
    } else if (tooFar) {
      // _speak("Come closer");
      // return null;
    }

    final shoulderPt = Offset(shoulder.x, shoulder.y);
    final elbowPt = Offset(elbow.x, elbow.y);
    final wristPt = Offset(wrist.x, wrist.y);

    double rawElbowAngle = PoseMath.calculateAngle(shoulderPt, elbowPt, wristPt);

    if (_smoothElbowAngle != null) {
      if ((rawElbowAngle - _smoothElbowAngle!).abs() > 50) {
        _jitterDrops++;
        if (_jitterDrops < 5) {
          return null;
        }
      } else {
        _jitterDrops = 0;
      }
    }

    final double alpha = 0.4;
    if (_jitterDrops == 0) {
      _smoothElbowAngle = _smoothElbowAngle != null
          ? (alpha * rawElbowAngle + (1 - alpha) * _smoothElbowAngle!)
          : rawElbowAngle;
    } else {
      _smoothElbowAngle = rawElbowAngle;
      _jitterDrops = 0;
    }

    bool badForm = false;
    // Disabled "Fix your elbow" strict detections that were firing incorrectly
    double currentElbowX = elbow.x;
    if (_lastElbowX != null) {
      // double elbowShift = (currentElbowX - _lastElbowX!).abs() * w;
      // if (elbowShift > 40) { badForm = true; } // To aggressive on jitter
    }
    _lastElbowX = currentElbowX;
    
    // double wristMovement = (wrist.x - elbow.x).abs() * w;
    // if (wristMovement > 120) { badForm = true; } // Fires on natural curling motion

    return _BicepCurlMetrics(elbowAngle: _smoothElbowAngle!, badForm: badForm);
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
    final reps = _latest?.reps ?? _bicepCurlAnalyzer.reps;
    final stage = _latest?.stage ?? 'Down';
    final angleFeedback = _latest?.angleFeedback ?? '';

    // Progress
    final elbowAngle = _latest?.elbowAngle ?? 0;
    // 30 is curled up, 160 is fully down. Progress 1.0 when curled up.
    final val = elbowAngle.clamp(30.0, 160.0);
    final progress = 1.0 - ((val - 30) / (160 - 30));

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
                                  elbowAngle: _latest?.elbowAngle,
                                  useLeft: _useLeft,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Progress Bar on the Right
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
                            color: progress > 0.8 ? Colors.green : Colors.amber,
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
                            'AI Fitness Trainer',
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
                                Text(
                                  '$reps',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                  ),
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
                                if (angleFeedback.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    angleFeedback,
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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

class _BicepCurlMetrics {
  const _BicepCurlMetrics({required this.elbowAngle, required this.badForm});

  final double elbowAngle;
  final bool badForm;
}

class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    required this.statusColor,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
    this.elbowAngle,
    this.useLeft = true,
  });

  final Pose pose;
  final Color statusColor;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;
  final double? elbowAngle;
  final bool useLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = statusColor;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = statusColor;

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

    final shoulder = getOffset(
      useLeft ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder,
    );
    final elbow = getOffset(
      useLeft ? PoseLandmarkType.leftElbow : PoseLandmarkType.rightElbow,
    );
    final wrist = getOffset(
      useLeft ? PoseLandmarkType.leftWrist : PoseLandmarkType.rightWrist,
    );
    final hip = getOffset(
      useLeft ? PoseLandmarkType.leftHip : PoseLandmarkType.rightHip,
    );

    void drawSafeLine(Offset? p1, Offset? p2) {
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }

    drawSafeLine(shoulder, elbow);
    drawSafeLine(elbow, wrist);
    drawSafeLine(shoulder, hip);

    final allJoints = [shoulder, elbow, wrist, hip];

    for (final pt in allJoints) {
      if (pt != null) {
        canvas.drawCircle(pt, 6.0, circlePaint);
      }
    }

    if (shoulder != null && elbow != null && wrist != null && hip != null) {
      // Calculate Bounding Box
      final xMin = [
        shoulder.dx,
        elbow.dx,
        wrist.dx,
        hip.dx,
      ].reduce((curr, next) => curr < next ? curr : next);
      final yMin = [
        shoulder.dy,
        elbow.dy,
        wrist.dy,
        hip.dy,
      ].reduce((curr, next) => curr < next ? curr : next);
      final xMax = [
        shoulder.dx,
        elbow.dx,
        wrist.dx,
        hip.dx,
      ].reduce((curr, next) => curr > next ? curr : next);
      final yMax = [
        shoulder.dy,
        elbow.dy,
        wrist.dy,
        hip.dy,
      ].reduce((curr, next) => curr > next ? curr : next);

      final pad = 20.0;
      final rect = Rect.fromLTRB(
        xMin - pad,
        yMin - pad,
        xMax + pad,
        yMax + pad,
      );
      canvas.drawRect(rect, boxPaint);

      // Draw corners
      final double lenCorner = 20.0;
      final cornerPaint = Paint()
        ..color = statusColor
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(xMin - pad, yMin - pad),
        Offset(xMin - pad + lenCorner, yMin - pad),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(xMin - pad, yMin - pad),
        Offset(xMin - pad, yMin - pad + lenCorner),
        cornerPaint,
      );
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

    drawAngle(elbowAngle, elbow);
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
