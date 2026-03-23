import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/app_colors.dart';

class ArViewScreen extends StatefulWidget {
  final String selectedSeat;
  const ArViewScreen({Key? key, this.selectedSeat = 'D3'}) : super(key: key);

  @override
  State<ArViewScreen> createState() => _ArViewScreenState();
}

class _ArViewScreenState extends State<ArViewScreen>
    with TickerProviderStateMixin {
  bool _isCameraMode = false;

  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
  }

  void _toggleCameraMode() {
    setState(() => _isCameraMode = !_isCameraMode);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AR Cinema View',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _isCameraMode
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _isCameraMode ? Icons.view_in_ar : Icons.camera_alt,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _toggleCameraMode,
              tooltip: _isCameraMode ? 'Switch to 3D View' : 'Switch to AR Camera',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background: simulated camera or gradient
          if (_isCameraMode)
            _buildSimulatedCameraBackground()
          else
            _buildGradientBackground(),

          // 3D Cinema Hall overlay
          AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _pulseController]),
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotationAnimation.value),
                child: CustomPaint(
                  painter: CinemaHallPainter(
                    selectedSeat: widget.selectedSeat,
                    opacity: _isCameraMode ? 0.75 : 1.0,
                    pulseValue: _pulseAnimation.value,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          ),

          // AR scan line effect when in camera mode
          if (_isCameraMode)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * _scanAnimation.value,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withOpacity(0.6),
                          AppColors.secondary.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Bottom info panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildInfoPanel(),
          ),

          // Mode badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isCameraMode
                      ? Colors.green.withOpacity(0.8)
                      : AppColors.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isCameraMode ? Colors.green : AppColors.primary)
                              .withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCameraMode ? Icons.camera_alt : Icons.view_in_ar,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCameraMode ? 'AR Camera Mode' : '3D Preview Mode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AR corner markers when in camera mode
          if (_isCameraMode) ..._buildCornerMarkers(context),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const markerSize = 30.0;
    const offset = 40.0;

    return [
      // Top-left
      Positioned(
        top: MediaQuery.of(context).padding.top + 90,
        left: offset,
        child: _buildCornerMarker(true, true),
      ),
      // Top-right
      Positioned(
        top: MediaQuery.of(context).padding.top + 90,
        right: offset,
        child: _buildCornerMarker(true, false),
      ),
      // Bottom-left
      Positioned(
        bottom: 180,
        left: offset,
        child: _buildCornerMarker(false, true),
      ),
      // Bottom-right
      Positioned(
        bottom: 180,
        right: offset,
        child: _buildCornerMarker(false, false),
      ),
    ];
  }

  Widget _buildCornerMarker(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: AppColors.secondary.withOpacity(0.8), width: 2)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: AppColors.secondary.withOpacity(0.8), width: 2)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: AppColors.secondary.withOpacity(0.8), width: 2)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: AppColors.secondary.withOpacity(0.8), width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSimulatedCameraBackground() {
    // Simulated AR camera view with animated grid and depth effect
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.3 * sin(_scanAnimation.value * 2 * pi),
                0.2 * cos(_scanAnimation.value * 2 * pi),
              ),
              radius: 1.2,
              colors: [
                const Color(0xFF1A2332),
                const Color(0xFF0F1923),
                const Color(0xFF0A1015),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: ArGridPainter(
              animValue: _scanAnimation.value,
              pulseValue: _pulseAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0D2B),
            const Color(0xFF1A1A3E),
            AppColors.primary.withOpacity(0.3),
            const Color(0xFF0D0D2B),
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seat info row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                Icons.event_seat,
                'Your Seat',
                widget.selectedSeat,
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                Icons.visibility,
                'View Quality',
                _getViewQuality(widget.selectedSeat),
                AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Instruction text
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _isCameraMode ? Icons.phone_android : Icons.touch_app,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isCameraMode
                        ? 'AR mode active — viewing cinema hall through simulated camera'
                        : 'This is your view from seat ${widget.selectedSeat}. Tap the camera icon to enable AR mode.',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  String _getViewQuality(String seat) {
    final row = seat.isNotEmpty ? seat[0].toUpperCase() : 'D';
    switch (row) {
      case 'A':
      case 'B':
        return 'Close';
      case 'C':
      case 'D':
      case 'E':
        return 'Ideal';
      case 'F':
      case 'G':
        return 'Good';
      default:
        return 'Far';
    }
  }
}

// ─────────────────────────────────────────────────
// AR Grid Painter — simulated camera background
// ─────────────────────────────────────────────────
class ArGridPainter extends CustomPainter {
  final double animValue;
  final double pulseValue;

  ArGridPainter({required this.animValue, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Perspective grid lines
    final gridPaint = Paint()
      ..color = Color.fromRGBO(0, 200, 150, 0.08 + 0.04 * pulseValue)
      ..strokeWidth = 0.5;

    // Horizontal lines with perspective
    for (int i = 0; i < 20; i++) {
      final t = i / 20.0;
      final y = h * t;
      final perspOffset = (t - 0.5) * 20 * sin(animValue * 2 * pi);
      canvas.drawLine(
        Offset(0, y + perspOffset),
        Offset(w, y + perspOffset),
        gridPaint,
      );
    }

    // Vertical lines with perspective convergence
    final vpX = w * (0.5 + 0.05 * sin(animValue * 2 * pi));
    final vpY = h * 0.35;
    for (int i = 0; i < 12; i++) {
      final x = w * (i / 11.0);
      canvas.drawLine(
        Offset(x, h),
        Offset(vpX + (x - vpX) * 0.3, vpY),
        gridPaint,
      );
    }

    // Floating data points
    final dotPaint = Paint()
      ..color = Color.fromRGBO(0, 200, 150, 0.15 + 0.1 * pulseValue);
    final rng = Random(42);
    for (int i = 0; i < 30; i++) {
      final dx = rng.nextDouble() * w;
      final dy = rng.nextDouble() * h;
      final r = 1.0 + rng.nextDouble() * 2;
      final phase = rng.nextDouble() * 2 * pi;
      final offsetY = sin(animValue * 2 * pi + phase) * 5;
      canvas.drawCircle(Offset(dx, dy + offsetY), r, dotPaint);
    }

    // "AR SCAN" crosshair in center
    final crossPaint = Paint()
      ..color = Color.fromRGBO(0, 200, 150, 0.2 + 0.15 * pulseValue)
      ..strokeWidth = 1;
    final cx = w / 2;
    final cy = h * 0.45;
    final crossSize = 20.0 + 5 * pulseValue;
    canvas.drawLine(Offset(cx - crossSize, cy), Offset(cx + crossSize, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - crossSize), Offset(cx, cy + crossSize), crossPaint);

    // Circle around crosshair
    final circlePaint = Paint()
      ..color = Color.fromRGBO(0, 200, 150, 0.1 + 0.08 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), crossSize * 1.5, circlePaint);
  }

  @override
  bool shouldRepaint(covariant ArGridPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────
// Custom Painter for the 3D Cinema Hall
// ─────────────────────────────────────────────────
class CinemaHallPainter extends CustomPainter {
  final String selectedSeat;
  final double opacity;
  final double pulseValue;

  CinemaHallPainter({
    required this.selectedSeat,
    this.opacity = 1.0,
    this.pulseValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vanishing point
    final vpX = w * 0.5;
    final vpY = h * 0.28;

    // Floor corners (near = bottom of screen, far = vanishing point area)
    final floorNearLeft = Offset(0, h * 0.95);
    final floorNearRight = Offset(w, h * 0.95);
    final floorFarLeft = Offset(w * 0.15, vpY + h * 0.15);
    final floorFarRight = Offset(w * 0.85, vpY + h * 0.15);

    // ── Draw ceiling ──
    final ceilingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(30, 20, 60, opacity),
          Color.fromRGBO(15, 10, 35, opacity * 0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.4));

    final ceilingPath = Path()
      ..moveTo(w * 0.15, vpY - h * 0.05)
      ..lineTo(w * 0.85, vpY - h * 0.05)
      ..lineTo(w, h * 0.15)
      ..lineTo(0, h * 0.15)
      ..close();
    canvas.drawPath(ceilingPath, ceilingPaint);

    // Ceiling lights
    for (int i = 1; i < 6; i++) {
      final t = i / 6.0;
      final lx = w * (0.25 + t * 0.5);
      final ly = vpY - h * 0.03 + t * h * 0.01;
      final lightPaint = Paint()
        ..color = Color.fromRGBO(255, 184, 0, 0.3 * opacity * pulseValue)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(lx, ly), 4 + pulseValue * 2, lightPaint);
    }

    // ── Draw left wall ──
    final leftWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromRGBO(40, 25, 70, opacity * 0.9),
          Color.fromRGBO(20, 12, 40, opacity * 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w * 0.3, h));

    final leftWallPath = Path()
      ..moveTo(0, h * 0.15)
      ..lineTo(w * 0.15, vpY - h * 0.05)
      ..lineTo(floorFarLeft.dx, floorFarLeft.dy)
      ..lineTo(floorNearLeft.dx, floorNearLeft.dy)
      ..close();
    canvas.drawPath(leftWallPath, leftWallPaint);

    // Left wall light strips
    for (int i = 0; i < 4; i++) {
      final t = (i + 1) / 5.0;
      final stripPaint = Paint()
        ..color = Color.fromRGBO(139, 37, 242, 0.2 * opacity * pulseValue)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final y1 = h * 0.15 + t * (h * 0.8);
      final x1 = 0 + t * w * 0.15 * 0.3;
      final x2 = x1 + w * 0.06;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y1), stripPaint);
    }

    // ── Draw right wall ──
    final rightWallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color.fromRGBO(40, 25, 70, opacity * 0.9),
          Color.fromRGBO(20, 12, 40, opacity * 0.6),
        ],
      ).createShader(Rect.fromLTWH(w * 0.7, 0, w * 0.3, h));

    final rightWallPath = Path()
      ..moveTo(w, h * 0.15)
      ..lineTo(w * 0.85, vpY - h * 0.05)
      ..lineTo(floorFarRight.dx, floorFarRight.dy)
      ..lineTo(floorNearRight.dx, floorNearRight.dy)
      ..close();
    canvas.drawPath(rightWallPath, rightWallPaint);

    // Right wall light strips
    for (int i = 0; i < 4; i++) {
      final t = (i + 1) / 5.0;
      final stripPaint = Paint()
        ..color = Color.fromRGBO(139, 37, 242, 0.2 * opacity * pulseValue)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final y1 = h * 0.15 + t * (h * 0.8);
      final x1 = w - t * w * 0.15 * 0.3;
      final x2 = x1 - w * 0.06;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y1), stripPaint);
    }

    // ── Draw floor ──
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(20, 12, 40, opacity * 0.8),
          Color.fromRGBO(35, 20, 55, opacity * 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, vpY, w, h - vpY));

    final floorPath = Path()
      ..moveTo(floorFarLeft.dx, floorFarLeft.dy)
      ..lineTo(floorFarRight.dx, floorFarRight.dy)
      ..lineTo(floorNearRight.dx, floorNearRight.dy)
      ..lineTo(floorNearLeft.dx, floorNearLeft.dy)
      ..close();
    canvas.drawPath(floorPath, floorPaint);

    // Floor aisle lines
    final aislePaint = Paint()
      ..color = Color.fromRGBO(139, 37, 242, 0.15 * opacity)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(vpX, floorFarLeft.dy),
      Offset(vpX, floorNearLeft.dy),
      aislePaint,
    );

    // ── Draw cinema screen ──
    final screenLeft = Offset(w * 0.2, vpY + h * 0.02);
    final screenRight = Offset(w * 0.8, vpY + h * 0.02);
    final screenBottom = vpY + h * 0.14;

    // Screen glow
    final glowPaint = Paint()
      ..color = Color.fromRGBO(100, 150, 255, 0.15 * opacity * pulseValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRect(
      Rect.fromLTRB(screenLeft.dx - 20, screenLeft.dy - 10,
          screenRight.dx + 20, screenBottom + 20),
      glowPaint,
    );

    // Screen surface
    final screenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(180, 200, 255, opacity * 0.95),
          Color.fromRGBO(120, 160, 220, opacity * 0.85),
        ],
      ).createShader(Rect.fromLTRB(
          screenLeft.dx, screenLeft.dy, screenRight.dx, screenBottom));

    final screenPath = Path()
      ..moveTo(screenLeft.dx, screenLeft.dy)
      ..lineTo(screenRight.dx, screenRight.dy)
      ..lineTo(screenRight.dx + 5, screenBottom)
      ..lineTo(screenLeft.dx - 5, screenBottom)
      ..close();
    canvas.drawPath(screenPath, screenPaint);

    // Screen border
    final screenBorderPaint = Paint()
      ..color = Color.fromRGBO(200, 210, 255, opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(screenPath, screenBorderPaint);

    // "SCREEN" label
    final screenTextPainter = TextPainter(
      text: TextSpan(
        text: '◀ SCREEN ▶',
        style: TextStyle(
          color: Color.fromRGBO(200, 210, 255, opacity * 0.5),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    screenTextPainter.layout();
    screenTextPainter.paint(
      canvas,
      Offset(vpX - screenTextPainter.width / 2, screenBottom + 6),
    );

    // ── Draw seat rows ──
    final int totalRows = 8;
    final int seatsPerSide = 3;
    final selectedRow = selectedSeat.isNotEmpty
        ? selectedSeat[0].toUpperCase().codeUnitAt(0) - 65
        : 3;
    final selectedCol = selectedSeat.length > 1
        ? int.tryParse(selectedSeat.substring(1)) ?? 3
        : 3;

    for (int row = 0; row < totalRows; row++) {
      final t = (row + 1) / (totalRows + 1);
      final perspectiveScale = 0.3 + t * 0.7;

      final rowY =
          floorFarLeft.dy + t * (floorNearLeft.dy - floorFarLeft.dy) * 0.85;
      final rowLeftEdge =
          floorFarLeft.dx + t * (floorNearLeft.dx - floorFarLeft.dx);
      final rowRightEdge =
          floorFarRight.dx + t * (floorNearRight.dx - floorFarRight.dx);
      final rowWidth = rowRightEdge - rowLeftEdge;

      final seatWidth = (rowWidth * 0.35) / seatsPerSide;
      final seatHeight = seatWidth * 0.6 * perspectiveScale;
      final gap = rowWidth * 0.30;

      final rowChar = String.fromCharCode(65 + row);

      // Left group of seats
      for (int col = 0; col < seatsPerSide; col++) {
        final sx = rowLeftEdge + rowWidth * 0.05 + col * seatWidth * 1.1;
        final sy = rowY;
        final seatCol = col + 1;
        final isMySeat = (row == selectedRow && seatCol == selectedCol);

        _drawSeat(canvas, sx, sy, seatWidth * 0.85, seatHeight, isMySeat,
            '$rowChar$seatCol', opacity, perspectiveScale);
      }

      // Right group of seats
      for (int col = 0; col < seatsPerSide; col++) {
        final sx = rowLeftEdge +
            rowWidth * 0.05 +
            seatsPerSide * seatWidth * 1.1 +
            gap +
            col * seatWidth * 1.1;
        final sy = rowY;
        final seatCol = col + seatsPerSide + 3; // skip aisle columns 4,5
        final isMySeat = (row == selectedRow && seatCol == selectedCol);

        _drawSeat(canvas, sx, sy, seatWidth * 0.85, seatHeight, isMySeat,
            '$rowChar$seatCol', opacity, perspectiveScale);
      }

      // Row label
      if (perspectiveScale > 0.5) {
        final labelPainter = TextPainter(
          text: TextSpan(
            text: rowChar,
            style: TextStyle(
              color: Color.fromRGBO(200, 200, 255, opacity * 0.4),
              fontSize: 8 * perspectiveScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(rowLeftEdge - 12, rowY));
      }
    }
  }

  void _drawSeat(Canvas canvas, double x, double y, double w, double h,
      bool isSelected, String label, double opacity, double scale) {
    final seatRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(2 * scale),
    );

    // Seat glow for selected
    if (isSelected) {
      final glowPaint = Paint()
        ..color = Color.fromRGBO(139, 37, 242, 0.5 * opacity * pulseValue)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale);
      canvas.drawRRect(seatRect, glowPaint);
    }

    // Seat back (slightly above)
    final backRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y - h * 0.4, w, h * 0.45),
      Radius.circular(2 * scale),
    );

    final backPaint = Paint()
      ..color = isSelected
          ? Color.fromRGBO(139, 37, 242, opacity)
          : Color.fromRGBO(60, 40, 90, opacity * 0.8);
    canvas.drawRRect(backRect, backPaint);

    // Seat cushion
    final cushionPaint = Paint()
      ..color = isSelected
          ? Color.fromRGBO(170, 80, 255, opacity)
          : Color.fromRGBO(50, 30, 75, opacity * 0.7);
    canvas.drawRRect(seatRect, cushionPaint);

    // Seat border
    final borderPaint = Paint()
      ..color = isSelected
          ? Color.fromRGBO(200, 130, 255, opacity * 0.8)
          : Color.fromRGBO(80, 60, 120, opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.5 : 0.5;
    canvas.drawRRect(seatRect, borderPaint);

    // Label on selected seat
    if (isSelected && scale > 0.5) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, opacity),
            fontSize: max(6, 7 * scale),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
          canvas, Offset(x + (w - tp.width) / 2, y + (h - tp.height) / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CinemaHallPainter oldDelegate) => true;
}
