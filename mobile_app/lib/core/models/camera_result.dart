// lib/core/models/camera_result.dart

class CameraResult {
  final String imagePath;
  final bool aiImageVerified;
  final bool aiBlurPassed;
  final String? aiObjectLabel;

  const CameraResult({
    required this.imagePath,
    required this.aiImageVerified,
    required this.aiBlurPassed,
    this.aiObjectLabel,
  });
}
