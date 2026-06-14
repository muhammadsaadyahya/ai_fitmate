import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/plank_analyzer.dart';
import '../utils/pose_math.dart';

class PlankPoseCorrectorScreen extends StatefulWidget {
  const PlankPoseCorrectorScreen({super.key});

  @override
  State<PlankPoseCorrectorScreen> createState() =>
      _PlankPoseCorrectorScreenState();
}

class _PlankPoseCorrectorScreenState extends State<PlankPoseCorrectorScreen> {
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

  late final PoseDetector _poseDetector;
  final PlankAnalyzer _plankAnalyzer = PlankAnalyzer();
  late final FlutterTts _flutterTts;
  DateTime? _lastSpeechTime;
  static const int _speechCooldownMs = 2500;

  bool _isDetecting = false;
  DateTime? _lastFrameTs;

  Pose? _currentPose;
  Size? _currentImageSize;
  InputImageRotation? _currentImageRotation;

  double _timeHeldSeconds = 0;
  PlankAnalysisResult? _latest;
  String _fallbackStatus = 'Point the camera at your body';
  Color _fallbackColor = Colors.white;

  void _speak(String text) async {
    if (text == 'Waiting...' ||
        text == 'Perfect Form' ||
        text.startsWith('Point'))
      return;
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

    _plankAnalyzer.resetSmoothing();
    _latest = null;
    _timeHeldSeconds = 0;
    _lastFrameTs = null;
    _currentPose = null;
    _currentImageSize = null;
    _currentImageRotation = null;
    _fallbackStatus = 'Point the camera at your body';
    _fallbackColor = Colors.white;

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

      final dt = now.difference(_lastFrameTs!).inMilliseconds / 1000.0;
      _lastFrameTs = now;

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final computed = _computePlank(pose);
        if (computed != null) {
          final result = _plankAnalyzer.analyze(
            rawHipAngle: computed.hip,
            rawKneeAngle: computed.knee,
            rawElbowAngle: computed.elbow,
          );

          if (!result.isBad) {
            _timeHeldSeconds += dt;
          } else {
            _speak(result.status);
          }

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
          _fallbackStatus = 'No pose detected — try a side view';
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

  _RawAngles? _computePlank(Pose pose) {
    PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder =
        pose.landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    PoseLandmark? rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    PoseLandmark? leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    PoseLandmark? rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    PoseLandmark? leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    PoseLandmark? rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    double scoreSide(
      PoseLandmark? shoulder,
      PoseLandmark? elbow,
      PoseLandmark? wrist,
      PoseLandmark? hip,
      PoseLandmark? knee,
      PoseLandmark? ankle,
    ) {
      return (shoulder?.likelihood ?? 0) +
          (elbow?.likelihood ?? 0) +
          (wrist?.likelihood ?? 0) +
          (hip?.likelihood ?? 0) +
          (knee?.likelihood ?? 0) +
          (ankle?.likelihood ?? 0);
    }

    final leftScore = scoreSide(
      leftShoulder,
      leftElbow,
      leftWrist,
      leftHip,
      leftKnee,
      leftAnkle,
    );
    final rightScore = scoreSide(
      rightShoulder,
      rightElbow,
      rightWrist,
      rightHip,
      rightKnee,
      rightAnkle,
    );

    final useLeft = leftScore >= rightScore;

    PoseLandmark? shoulder = useLeft ? leftShoulder : rightShoulder;
    PoseLandmark? elbow = useLeft ? leftElbow : rightElbow;
    PoseLandmark? wrist = useLeft ? leftWrist : rightWrist;
    PoseLandmark? hip = useLeft ? leftHip : rightHip;
    PoseLandmark? knee = useLeft ? leftKnee : rightKnee;
    PoseLandmark? ankle = useLeft ? leftAnkle : rightAnkle;

    final selected = [shoulder, elbow, wrist, hip, knee, ankle];
    if (selected.any(
      (lm) => lm == null || lm.likelihood < _minLandmarkConfidence,
    )) {
      return null;
    }

    final shoulderPt = Offset(shoulder!.x, shoulder.y);
    final elbowPt = Offset(elbow!.x, elbow.y);
    final wristPt = Offset(wrist!.x, wrist.y);
    final hipPt = Offset(hip!.x, hip.y);
    final kneePt = Offset(knee!.x, knee.y);
    final anklePt = Offset(ankle!.x, ankle.y);

    final hipAngle = PoseMath.calculateAngle(shoulderPt, hipPt, anklePt);
    final kneeAngle = PoseMath.calculateAngle(hipPt, kneePt, anklePt);
    final elbowAngle = PoseMath.calculateAngle(shoulderPt, elbowPt, wristPt);

    return _RawAngles(hip: hipAngle, knee: kneeAngle, elbow: elbowAngle);
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
                            'Plank Pose Corrector',
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
                                  'TIME HELD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${_timeHeldSeconds.toStringAsFixed(1)} s',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
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
                                const SizedBox(height: 10),
                                if (_latest != null)
                                  Text(
                                    'HIP: ${_latest!.hipAngle.round()}   KNEE: ${_latest!.kneeAngle.round()}   ELBOW: ${_latest!.elbowAngle.round()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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

class _RawAngles {
  const _RawAngles({
    required this.hip,
    required this.knee,
    required this.elbow,
  });

  final double hip;
  final double knee;
  final double elbow;
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

    // Helper to safely convert landmarks to screen offsets
    Offset? getOffset(PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm == null) return null;
      return Offset(translateX(lm.x), translateY(lm.y));
    }

    // Extract all necessary points
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

    // Helper to draw a line only if both points exist
    void drawSafeLine(Offset? p1, Offset? p2) {
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }

    // --- Draw Torso ---
    drawSafeLine(leftShoulder, rightShoulder); // Top of shoulders
    drawSafeLine(leftHip, rightHip); // Pelvis
    drawSafeLine(leftShoulder, leftHip); // Left torso
    drawSafeLine(rightShoulder, rightHip); // Right torso

    // --- Draw Left Arm & Leg ---
    drawSafeLine(leftShoulder, leftElbow);
    drawSafeLine(leftElbow, leftWrist);
    drawSafeLine(leftHip, leftKnee);
    drawSafeLine(leftKnee, leftAnkle);

    // --- Draw Right Arm & Leg ---
    drawSafeLine(rightShoulder, rightElbow);
    drawSafeLine(rightElbow, rightWrist);
    drawSafeLine(rightHip, rightKnee);
    drawSafeLine(rightKnee, rightAnkle);

    // --- Draw Joints ---
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
