// lib/features/listing/camera_screen.dart
//
// KEY CHANGE from previous version:
//   Navigator.pop() now returns a CameraResult object (not just a String path)
//   so listing_screen.dart gets aiImageVerified, aiBlurPassed, and aiObjectLabel
//   to send to the Node backend.

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'dart:ui';
import '../../core/theme/aura_theme.dart';
// Import CameraResult from listing_screen
import 'listing_screen.dart' show CameraResult;

const Map<String, List<String>> _categoryKeywords = {
  'Electronics': [
    'cell phone',
    'mobile phone',
    'handheld',
    'laptop',
    'computer',
    'keyboard',
    'monitor',
    'remote',
  ],
  'Smartphones': ['cell phone', 'mobile phone', 'handheld'],
  'Computers': ['laptop', 'computer', 'keyboard', 'mouse', 'monitor'],
  'Home Goods': [
    'chair',
    'couch',
    'table',
    'sofa',
    'bed',
    'cup',
    'bowl',
    'vase',
    'lamp',
  ],
  'Clothing': ['clothing', 'shirt', 'shoe', 'hat', 'dress', 'bag', 'suitcase'],
  'Books': ['book', 'magazine', 'notebook'],
  'Bicycle': ['bicycle', 'bike'],
  'Vehicles': ['car', 'motorcycle', 'vehicle', 'truck'],
  'Furniture': ['chair', 'couch', 'table', 'sofa', 'bed', 'shelf'],
};

const double _blurThreshold = 100.0;

class CameraScreen extends StatefulWidget {
  final String expectedCategory;
  const CameraScreen({super.key, required this.expectedCategory});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _flashOn = false;

  ObjectDetector? _detector;
  bool _objectDetected = false;
  String _detectedLabel = '';
  bool _isProcessingFrame = false;
  bool _isBlurry = false;

  late AnimationController _scanAnimController;
  late Animation<double> _scanAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCamera();
    _initDetector();
  }

  void _initAnimations() {
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _startCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    _controller = controller;
    await controller.initialize();
    if (!mounted) return;
    await controller.startImageStream(_processCameraFrame);
    setState(() => _isCameraReady = true);
  }

  Future<void> _initDetector() async {
    _detector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: false,
      ),
    );
  }

  Future<void> _processCameraFrame(CameraImage frame) async {
    if (_isProcessingFrame || _detector == null) return;
    _isProcessingFrame = true;
    try {
      // Flatten all planes into one Uint8List without needing WriteBuffer
      final allBytes = frame.planes
          .map((p) => p.bytes)
          .reduce((a, b) => Uint8List.fromList([...a, ...b]));

      final inputImage = InputImage.fromBytes(
        bytes: allBytes,
        metadata: InputImageMetadata(
          size: Size(frame.width.toDouble(), frame.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: frame.planes[0].bytesPerRow,
        ),
      );

      final objects = await _detector!.processImage(inputImage);
      final keywords = _categoryKeywords[widget.expectedCategory] ?? [];

      bool found = false;
      String foundLabel = '';
      for (final obj in objects) {
        for (final label in obj.labels) {
          if (label.confidence > 0.5 &&
              keywords.any((kw) => label.text.toLowerCase().contains(kw))) {
            found = true;
            foundLabel = label.text;
            break;
          }
        }
        if (found) break;
      }

      if (mounted) {
        setState(() {
          _objectDetected = found;
          _detectedLabel = foundLabel;
        });
      }
    } finally {
      _isProcessingFrame = false;
    }
  }

  double _laplacianVariance(Uint8List jpegBytes) {
    final decoded = img.decodeImage(jpegBytes);
    if (decoded == null) return 0;
    final gray = img.grayscale(decoded);
    final List<double> lap = [];
    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final c = img.getLuminance(gray.getPixel(x, y)).toDouble();
        final t = img.getLuminance(gray.getPixel(x, y - 1)).toDouble();
        final b = img.getLuminance(gray.getPixel(x, y + 1)).toDouble();
        final l = img.getLuminance(gray.getPixel(x - 1, y)).toDouble();
        final r = img.getLuminance(gray.getPixel(x + 1, y)).toDouble();
        lap.add((t + b + l + r - 4 * c).abs());
      }
    }
    final mean = lap.reduce((a, b) => a + b) / lap.length;
    return lap.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
        lap.length;
  }

  Future<void> _onCapture() async {
    if (_controller == null || !_objectDetected) return;

    await _controller!.stopImageStream();
    final file = await _controller!.takePicture();
    final bytes = await file.readAsBytes();
    final variance = _laplacianVariance(bytes);

    if (variance < _blurThreshold) {
      setState(() => _isBlurry = true);
      await _controller!.startImageStream(_processCameraFrame);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isBlurry = false);
      });
      return;
    }

    // ── Pop a CameraResult (not just a String) so listing_screen gets all flags ──
    if (mounted) {
      Navigator.pop(
        context,
        CameraResult(
          imagePath: file.path,
          aiImageVerified: _objectDetected, // Step 5: TFLite passed
          aiBlurPassed: variance >= _blurThreshold, // Step 6: blur passed
          aiObjectLabel: _detectedLabel.isNotEmpty ? _detectedLabel : null,
        ),
      );
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    _flashOn = !_flashOn;
    await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller?.stopImageStream();
    await _controller?.dispose();
    setState(() => _isCameraReady = false);
    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _pulseController.dispose();
    _controller?.dispose();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraReady && _controller != null)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xFF0D1117),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AuraTheme.emeraldAccent,
                  ),
                ),
              ),
            ),

          // Detection overlay
          Positioned.fill(
            child: _DetectionOverlay(
              scanAnim: _scanAnim,
              objectDetected: _objectDetected,
              expectedCategory: widget.expectedCategory,
              detectedLabel: _detectedLabel,
            ),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: _objectDetected ? 1.0 : _pulseAnim.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _objectDetected
                              ? AuraTheme.primary.withOpacity(0.92)
                              : Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _objectDetected
                                ? AuraTheme.emeraldAccent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _objectDetected ? Icons.sensors : Icons.search,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _objectDetected
                                  ? (_detectedLabel.isNotEmpty
                                        ? _detectedLabel.toUpperCase()
                                        : 'DETECTED')
                                  : 'SCANNING...',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassButton(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        onTap: _toggleFlash,
                      ),
                      const SizedBox(height: 10),
                      _GlassButton(
                        icon: Icons.flip_camera_ios,
                        onTap: _flipCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Blur snackbar
          if (_isBlurry)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: _BlurSnackbar(
                onRetry: () => setState(() => _isBlurry = false),
              ),
            ),

          // Bottom capture bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCaptureBar(
              objectDetected: _objectDetected,
              expectedCategory: widget.expectedCategory,
              onCapture: _onCapture,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets (unchanged from previous version) ─────────────────────

class _DetectionOverlay extends StatelessWidget {
  final Animation<double> scanAnim;
  final bool objectDetected;
  final String expectedCategory;
  final String detectedLabel;

  const _DetectionOverlay({
    required this.scanAnim,
    required this.objectDetected,
    required this.expectedCategory,
    required this.detectedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = objectDetected
        ? AuraTheme.emeraldAccent
        : AuraTheme.emeraldAccent.withOpacity(0.45);

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.67,
        height: MediaQuery.of(context).size.height * 0.42,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
            ),
            AnimatedBuilder(
              animation: scanAnim,
              builder: (_, __) => Positioned(
                top: scanAnim.value * MediaQuery.of(context).size.height * 0.42,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        AuraTheme.emeraldAccent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildCorner(top: true, left: true, detected: objectDetected),
            _buildCorner(top: true, left: false, detected: objectDetected),
            _buildCorner(top: false, left: true, detected: objectDetected),
            _buildCorner(top: false, left: false, detected: objectDetected),
            Positioned(
              top: -36,
              left: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: objectDetected
                      ? AuraTheme.primary
                      : Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sensors, color: Colors.white, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      objectDetected
                          ? 'VERIFIED: ${detectedLabel.toUpperCase()}'
                          : 'DETECTING: ${expectedCategory.toUpperCase()}',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({
    required bool top,
    required bool left,
    required bool detected,
  }) {
    final color = detected ? AuraTheme.primary : AuraTheme.emeraldAccent;
    return Positioned(
      top: top ? -1 : null,
      bottom: !top ? -1 : null,
      left: left ? -1 : null,
      right: !left ? -1 : null,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(
          painter: _CornerPainter(
            color: color,
            thick: 3.5,
            top: top,
            left: left,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thick;
  final bool top, left;
  _CornerPainter({
    required this.color,
    required this.thick,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final ox = left ? 0.0 : size.width;
    final oy = top ? 0.0 : size.height;
    final ex = left ? size.width : 0.0;
    final ey = top ? size.height : 0.0;
    canvas.drawLine(Offset(ox, oy), Offset(ex, oy), paint);
    canvas.drawLine(Offset(ox, oy), Offset(ox, ey), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.top != top || old.left != left;
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

class _BlurSnackbar extends StatelessWidget {
  final VoidCallback onRetry;
  const _BlurSnackbar({required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: AuraTheme.onSurface,
      borderRadius: BorderRadius.circular(12),
      border: const Border(left: BorderSide(color: AuraTheme.error, width: 4)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: AuraTheme.errorContainer,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Image too blurry for AI verification. Please retake.',
            style: GoogleFonts.lexend(
              color: AuraTheme.surface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRetry,
          child: Text(
            'RETRY',
            style: GoogleFonts.lexend(
              color: AuraTheme.emeraldAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BottomCaptureBar extends StatelessWidget {
  final bool objectDetected;
  final String expectedCategory;
  final VoidCallback onCapture;
  const _BottomCaptureBar({
    required this.objectDetected,
    required this.expectedCategory,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.black.withOpacity(0.75), Colors.transparent],
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AuraTheme.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AuraTheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.lexend(
                color: AuraTheme.onSurface,
                fontSize: 13,
              ),
              children: [
                const TextSpan(text: 'Position the '),
                TextSpan(
                  text: expectedCategory,
                  style: const TextStyle(
                    color: AuraTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' within the frame to verify.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: objectDetected ? onCapture : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: objectDetected
                  ? AuraTheme.primary
                  : AuraTheme.outlineVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
              boxShadow: objectDetected
                  ? [
                      BoxShadow(
                        color: AuraTheme.primary.withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  color: objectDetected ? Colors.white : AuraTheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  objectDetected ? 'CAPTURE' : 'WAITING FOR DETECTION...',
                  style: GoogleFonts.lexend(
                    color: objectDetected ? Colors.white : AuraTheme.outline,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
