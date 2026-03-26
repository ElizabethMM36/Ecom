// lib/features/listing/listing_screen.dart
//
// Key changes vs previous version:
//  • _onSubmit() now builds a ListingSubmission and calls ApiService.submitListing()
//  • CameraScreen result carries aiImageVerified, aiBlurPassed, aiObjectLabel
//  • Loading state + error snackbar added
//  • Location from device GPS (geolocator) fed into submission

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/models/camera_result.dart';
import '../../core/theme/aura_theme.dart';
import '../../core/models/listing_draft.dart';
import '../../core/services/api_service.dart';
import 'camera_screen.dart';

import '../../widgets/form_fields.dart';

// ── Result from CameraScreen ──────────────────────────────────────────────────
// CameraScreen.pop() should return this object, not just a path string.
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

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _selectedCategory = 'Electronics';
  int _conditionIndex = 0;

  // Camera result
  CameraResult? _cameraResult;

  // Device GPS location
  double? _latitude;
  double? _longitude;

  // UI state
  bool _isSubmitting = false;
  bool _locationReady = false;

  bool get _canSubmit => _cameraResult != null && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  // ── Fetch GPS location on screen open ───────────────────────────────────────
  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationReady = true;
        });
      }
    } catch (e) {
      debugPrint('[GPS] Failed: $e');
    }
  }

  // ── Open CameraScreen ────────────────────────────────────────────────────────
  Future<void> _openCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showError('Camera permission is required to list an item.');
      return;
    }

    // Navigate to camera, get back a CameraResult
    final result = await Navigator.push<CameraResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(expectedCategory: _selectedCategory),
      ),
    );

    if (result != null && mounted) {
      setState(() => _cameraResult = result);
    }
  }

  // ── Submit listing ────────────────────────────────────────────────────────────
  Future<void> _onSubmit() async {
    if (!_canSubmit) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final conditionLabels = ['New', 'Like New', 'Used', 'Fair'];

      final submission = ListingSubmission(
        imagePath: _cameraResult!.imagePath,
        title: _titleCtrl.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceCtrl.text.trim()),
        description: _descCtrl.text.trim(),
        condition: conditionLabels[_conditionIndex],
        serialNumber: _serialCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        // Camera AI flags from Step 5 & 6
        aiImageVerified: _cameraResult!.aiImageVerified,
        aiBlurPassed: _cameraResult!.aiBlurPassed,
        aiObjectLabel: _cameraResult!.aiObjectLabel,
      );

      final response = await ApiService.submitListing(submission);

      if (!mounted) return;

      // Show review notice if flagged
      final note = response['verificationNote'] as String?;
      if (note != null) {
        _showInfo(note);
      } else {
        _showSuccess('Listing published successfully!');
      }

      // Navigate back or to listings page
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lexend()),
        backgroundColor: AuraTheme.error,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lexend()),
        backgroundColor: AuraTheme.primary,
      ),
    );
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lexend()),
        backgroundColor: const Color(0xFF7B5A00),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _serialCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraTheme.surface,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            // ── Camera section ───────────────────────────────────────────────
            _CameraSection(
              cameraResult: _cameraResult,
              selectedCategory: _selectedCategory,
              onTap: _openCamera,
              onRetake: () => setState(() => _cameraResult = null),
            ),
            const SizedBox(height: 28),

            // ── Form header ──────────────────────────────────────────────────
            Text(
              'Product Details',
              style: GoogleFonts.lexend(
                color: AuraTheme.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            const AuraFieldLabel('Title'),
            AuraTextField(
              placeholder: 'e.g. iPhone 15 Pro - 256GB - Blue Titanium',
              controller: _titleCtrl,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuraFieldLabel('Category'),
                      AuraCategoryDropdown(
                        value: _selectedCategory,
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuraFieldLabel('Price (₹)'),
                      AuraTextField(
                        placeholder: '0.00',
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        prefixText: '₹ ',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const AuraFieldLabel('Description'),
            AuraTextField(
              placeholder:
                  'Describe the item condition, history, and features...',
              controller: _descCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            const AuraFieldLabel('Serial Number'),
            AuraTextField(placeholder: 'Optional', controller: _serialCtrl),
            const SizedBox(height: 16),

            const AuraFieldLabel('Condition'),
            AuraConditionSelector(
              selectedIndex: _conditionIndex,
              onChanged: (i) => setState(() => _conditionIndex = i),
            ),
            const SizedBox(height: 16),

            const AuraFieldLabel('Item Location'),
            AuraTextField(
              placeholder: 'City, State',
              controller: _locationCtrl,
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AuraTheme.secondary,
                size: 20,
              ),
            ),

            // GPS status indicator
            if (_locationReady)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      color: AuraTheme.primary,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'GPS location captured',
                      style: GoogleFonts.lexend(
                        color: AuraTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // ── Submit button ─────────────────────────────────────────────────
            _SubmitButton(
              enabled: _canSubmit,
              isSubmitting: _isSubmitting,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _AuraBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AuraTheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AuraTheme.secondary),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        'Aura',
        style: GoogleFonts.lexend(
          color: AuraTheme.deepGreen,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
      actions: [
        Text(
          'List an Item',
          style: GoogleFonts.lexend(
            color: AuraTheme.deepGreen,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.help_outline, color: AuraTheme.secondary),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AuraTheme.outlineVariant.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ─── Camera section ───────────────────────────────────────────────────────────
class _CameraSection extends StatelessWidget {
  final CameraResult? cameraResult;
  final String selectedCategory;
  final VoidCallback onTap;
  final VoidCallback onRetake;

  const _CameraSection({
    required this.cameraResult,
    required this.selectedCategory,
    required this.onTap,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            if (cameraResult != null)
              Image.file(File(cameraResult!.imagePath), fit: BoxFit.cover)
            else
              Container(
                color: const Color(0xFF0D1117),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF2D4A3E),
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to open camera',
                      style: GoogleFonts.lexend(
                        color: const Color(0xFF4D7A64),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI will verify your $selectedCategory',
                      style: GoogleFonts.lexend(
                        color: const Color(0xFF2D4A3E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Tap overlay (no image)
            if (cameraResult == null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap),
                ),
              ),

            // AI verified badge
            if (cameraResult != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AuraTheme.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AuraTheme.emeraldAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'AI VERIFIED',
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

            // Detected label chip
            if (cameraResult?.aiObjectLabel != null)
              Positioned(
                top: 54,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cameraResult!.aiObjectLabel!.toUpperCase(),
                    style: GoogleFonts.lexend(
                      color: AuraTheme.emeraldAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // Retake button
            if (cameraResult != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: onRetake,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RETAKE',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Start detection button
            if (cameraResult == null)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AuraTheme.primary,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AuraTheme.primary.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'START DETECTION',
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom hint
            if (cameraResult == null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: AuraTheme.surface.withOpacity(0.92),
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
                          text: selectedCategory,
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
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Submit button ─────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: enabled
            ? AuraTheme.primary
            : AuraTheme.outlineVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AuraTheme.primary.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: isSubmitting
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        enabled
                            ? Icons.rocket_launch_rounded
                            : Icons.camera_alt,
                        color: enabled ? Colors.white : AuraTheme.outline,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        enabled
                            ? 'PUBLISH LISTING'
                            : 'WAITING FOR DETECTION...',
                        style: GoogleFonts.lexend(
                          color: enabled ? Colors.white : AuraTheme.outline,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom nav ────────────────────────────────────────────────────────────────
class _AuraBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AuraTheme.surface,
        border: Border(
          top: BorderSide(color: AuraTheme.outlineVariant.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, label: 'Home', active: false),
              _NavItem(icon: Icons.search, label: 'Browse', active: false),
              _NavItem(icon: Icons.add_circle, label: 'Sell', active: true),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                active: false,
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                active: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AuraTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.white : const Color(0xFF545F73),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lexend(
                color: active ? Colors.white : const Color(0xFF545F73),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
