import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final String workoutName;

  const CameraScreen({super.key, required this.workoutName});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape (horizontal)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera if available, otherwise use first camera
        final camera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
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
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Restore orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _toggleCamera() async {
    if (_controller == null || _cameras == null || _cameras!.length < 2) return;
    
    if (mounted) setState(() { _isInitialized = false; });

    final currentCamera = _controller!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => _cameras!.first,
    );

    await _controller?.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (mounted) {
      setState(() { _isInitialized = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: _isInitialized && _controller != null
          ? Stack(
              children: [
                // Camera Preview
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: width,
                      height: width / _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

                // Top bar with workout name and close button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.workoutName,
                                  style: TextStyle(
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: height * 0.005),
                                Row(
                                  children: [
                                    Container(
                                      width: width * 0.025,
                                      height: width * 0.025,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      _isRecording ? 'Recording' : 'Ready',
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                  ),
                ),

                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Flip Camera Button
                            if (_cameras != null && _cameras!.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white,
                                  size: width * 0.08,
                                ),
                                onPressed: _toggleCamera,
                              )
                            else
                              SizedBox(width: width * 0.08),

                            // Start/Stop Recording Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRecording = !_isRecording;
                                });
                              },
                              child: Container(
                                width: width * 0.18,
                                height: width * 0.18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: width * 0.14,
                                    height: width * 0.14,
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? Colors.red
                                          : const Color(0xFFCDFF00),
                                      shape: _isRecording
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      borderRadius: _isRecording
                                          ? BorderRadius.circular(8)
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Placeholder for symmetry
                            SizedBox(width: width * 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Overlay guides for posture
                if (!_isRecording)
                  Positioned.fill(
                    child: CustomPaint(painter: PostureGuidePainter()),
                  ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFCDFF00),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Custom painter for posture guide overlay
class PostureGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDFF00).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw body outline guide
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Head circle
    canvas.drawCircle(
      Offset(centerX, centerY - size.height * 0.15),
      size.width * 0.08,
      paint,
    );

    // Body line
    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.07),
      Offset(centerX, centerY + size.height * 0.15),
      paint,
    );

    // Arms
    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.05),
      Offset(centerX - size.width * 0.15, centerY + size.height * 0.05),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.05),
      Offset(centerX + size.width * 0.15, centerY + size.height * 0.05),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(centerX, centerY + size.height * 0.15),
      Offset(centerX - size.width * 0.08, centerY + size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + size.height * 0.15),
      Offset(centerX + size.width * 0.08, centerY + size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
