import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/domain/repositories/location_repository.dart';
import '../../../../core/domain/repositories/notification_repository.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/service_locator.dart';

const String sosMapboxPublicToken =
    String.fromEnvironment('MAPBOX_PUBLIC_TOKEN', defaultValue: '');

bool _isMapboxConfigured() => sosMapboxPublicToken.isNotEmpty;

const Color _primaryRed = Color(0xFFD32F2F);
const Color _darkText = Color(0xFF1A1A1A);
const Color _mutedText = Color(0xFF4A4A4A);
const Color _mapBackdrop = Color(0xFFE8E6DF);

const Duration _pulseDuration = Duration(milliseconds: 2600);
const Duration _cancelHoldDuration = Duration(milliseconds: 3000);
const Duration _sendBackstop = Duration(seconds: 8);

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  mb.MapboxMap? _mapController;
  late final mb.CameraViewportState _viewport = mb.CameraViewportState(
    center: mb.Point(coordinates: mb.Position(29.66, -1.03)),
    zoom: 15.0,
  );

  Park _park = Park.bwindiImpenetrable;
  String? _locationName;
  String? _locationError;
  double _lat = 0;
  double _lng = 0;
  bool _isSaving = false;
  String? _saveError;
  String? _savedIncidentId;
  bool _sent = false;
  bool _cancelQueued = false;
  Timer? _backstop;

  @override
  void initState() {
    super.initState();
    _captureLocation();
    _backstop = Timer(_sendBackstop, _maybeSend);
  }

  @override
  void dispose() {
    _backstop?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    final result = await sl<LocationRepository>().getCurrentLocation();
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _locationError = failure.message);
        _maybeSend();
      },
      (location) async {
        final name = await sl<LocationRepository>()
            .reverseGeocode(location.latitude, location.longitude);
        final detected = sl<LocationRepository>()
            .getParkFromLocation(location.latitude, location.longitude);
        if (!mounted) return;
        setState(() {
          _lat = location.latitude;
          _lng = location.longitude;
          _locationName = name;
          _park = Park.fromWire(detected);
        });
        _mapController?.flyTo(
          mb.CameraOptions(
            center: mb.Point(
              coordinates: mb.Position(location.longitude, location.latitude),
            ),
            zoom: 15.0,
          ),
          mb.MapAnimationOptions(duration: 800),
        );
        _maybeSend();
      },
    );
  }

  void _maybeSend() {
    if (_sent || _isSaving) return;
    final locationSettled = _locationName != null || _locationError != null;
    if (locationSettled) _send();
  }

  Future<void> _send() async {
    setState(() {
      _sent = true;
      _isSaving = true;
      _saveError = null;
    });
    final details = NewIncidentDetails(
      type: IncidentType.sos,
      park: _park,
      community: _locationName ?? 'Unknown',
      species: 'N/A',
      severity: IncidentSeverity.high,
      summary: 'SOS — requesting urgent responder assistance.',
      lat: _lat,
      lng: _lng,
      locationName: _locationName,
    );
    final result = await sl<IncidentRepository>().create(details);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _saveError = 'Failed to send SOS';
        });
      },
      (incident) async {
        await sl<NotificationRepository>().notifyPendingSync(incident.id);
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _savedIncidentId = incident.id;
        });
        if (_cancelQueued) {
          _cancelQueued = false;
          await sl<IncidentRepository>().withdraw(incident.id);
        }
      },
    );
  }

  Future<void> _cancelSos() async {
    final incidentId = _savedIncidentId;
    if (incidentId != null) {
      await sl<IncidentRepository>().withdraw(incidentId);
    } else {
      _cancelQueued = true;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: _mapBackdrop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMap(),
          _RedGradientOverlay(),
          const SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [SosRadar(), SosBadge()],
            ),
          ),
          Positioned(
            top: topInset + 16,
            left: 24,
            right: 24,
            child: const SosHeaderCard(),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomInset + 28,
            child: SosActionPanel(
              saveError: _saveError,
              onCancelSos: _cancelSos,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!_isMapboxConfigured()) {
      return const ColoredBox(color: _mapBackdrop);
    }
    return mb.MapWidget(
      styleUri: 'mapbox://styles/mapbox/streets-v12',
      viewport: _viewport,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}

class _RedGradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.55,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Color(0x8CD32F2F),
              Color(0xF2D32F2F),
            ],
          ),
        ),
      ),
    );
  }
}

class SosRadar extends StatefulWidget {
  const SosRadar({super.key});

  @override
  State<SosRadar> createState() => _SosRadarState();
}

class _SosRadarState extends State<SosRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _pulseDuration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(360, 360),
          painter: _RadarPainter(_controller.value),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double phase;
  _RadarPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final strokePaint = Paint()
      ..color = _primaryRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(
      center,
      maxRadius * 0.28,
      Paint()..color = _primaryRed.withValues(alpha: 0.06),
    );

    for (var i = 0; i < 3; i++) {
      final offset = (phase + i * 0.33) % 1.0;
      final radius = maxRadius * offset;
      final alpha = (1.0 - offset) * 0.5;
      strokePaint.color = _primaryRed.withValues(alpha: alpha);
      canvas.drawCircle(center, math.max(radius, 0.1), strokePaint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class SosBadge extends StatelessWidget {
  const SosBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _primaryRed,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.warning, size: 46, color: Colors.white),
    );
  }
}

class SosHeaderCard extends StatelessWidget {
  const SosHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'WILDLIFE SOS ACTIVE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'UWA Rangers & Community Patrols Notified',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SosActionPanel extends StatelessWidget {
  final String? saveError;
  final VoidCallback onCancelSos;
  const SosActionPanel({
    super.key,
    this.saveError,
    required this.onCancelSos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (saveError != null) ...[
          Text(
            saveError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Broadcasting your live location to response teams...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 18),
        HoldToCancelButton(onCancel: onCancelSos),
      ],
    );
  }
}

class HoldToCancelButton extends StatefulWidget {
  final VoidCallback onCancel;
  const HoldToCancelButton({super.key, required this.onCancel});

  @override
  State<HoldToCancelButton> createState() => _HoldToCancelButtonState();
}

class _HoldToCancelButtonState extends State<HoldToCancelButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cancelHoldDuration,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() => _controller.value = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Listener(
        onPointerDown: (_) => _controller.forward(from: 0),
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _controller.value,
                    heightFactor: 1,
                    child: Container(
                      color: _primaryRed.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                const Text(
                  'HOLD TO CANCEL SOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: _primaryRed,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}