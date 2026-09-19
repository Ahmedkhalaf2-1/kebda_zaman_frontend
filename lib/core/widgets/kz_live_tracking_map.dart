import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/maps_launcher.dart';
import 'package:kebda_zaman/core/utils/polyline_decoder.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';

/// The live-tracking map card shared by the customer order-tracking screen
/// and the admin order-details screen. Renders the backend's already-known
/// [OrderTracking] state — it never requests device location permission
/// itself and never fabricates a position: a driver marker is shown only
/// when [OrderTracking.location] is actually present, a destination marker
/// only when [destinationLat]/[destinationLng] are valid non-`(0,0)`
/// coordinates.
///
/// Camera behavior: the map frames both markers exactly once, the first
/// time a driver location becomes available. Every later rebuild (a normal
/// ~10s poll tick) moves the *marker* to the new position without touching
/// the camera — a user who has panned/zoomed away is never yanked back.
/// The [onRecenter] control (always visible once a driver location exists)
/// is the only way the camera moves again after that.
class KZLiveTrackingMap extends StatefulWidget {
  final OrderTracking tracking;
  final double? destinationLat;
  final double? destinationLng;

  const KZLiveTrackingMap({
    super.key,
    required this.tracking,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  State<KZLiveTrackingMap> createState() => _KZLiveTrackingMapState();
}

class _KZLiveTrackingMapState extends State<KZLiveTrackingMap>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  bool _hasFramedCamera = false;
  Timer? _ageTicker;

  // Smoothly tweens the driver marker between its previous and newest
  // reported fix instead of jumping every poll cycle — `_markerAnimation`
  // is only ever non-null while an animation from one real fix to another
  // is in flight; before the first fix (or once the animation completes)
  // the marker is drawn straight from `tracking.location`.
  late final AnimationController _markerAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
  Animation<LatLng>? _markerAnimation;
  LatLng? _lastAnimatedTarget;

  // The most recently rendered non-null route — kept on screen if a later
  // poll returns `encodedPolyline: null` (a transient Google Routes
  // failure), never cleared just because the newest response has no route.
  List<LatLng> _polylinePoints = const [];

  bool get _hasDestination =>
      widget.destinationLat != null &&
      widget.destinationLng != null &&
      !(widget.destinationLat == 0 && widget.destinationLng == 0);

  @override
  void initState() {
    super.initState();
    // Re-renders the "updated Xs ago" label once a second purely from the
    // local clock — this is what lets a STALE/no-longer-polling marker keep
    // visibly aging even without another server response, rather than a
    // frozen "12s ago" that silently goes wrong.
    _ageTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _syncPolyline(widget.tracking.encodedPolyline);
    final location = widget.tracking.location;
    if (location != null) {
      _lastAnimatedTarget = LatLng(location.latitude, location.longitude);
    }
  }

  @override
  void dispose() {
    _ageTicker?.cancel();
    _markerAnimationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _syncPolyline(String? encoded) {
    // A `null`/empty route from this poll is not a signal to clear the
    // line — only a genuinely new non-empty route replaces it.
    if (encoded == null || encoded.isEmpty) return;
    final decoded = decodePolyline(encoded);
    if (decoded.isEmpty) return;
    _polylinePoints = decoded
        .map((p) => LatLng(p.$1, p.$2))
        .toList(growable: false);
  }

  void _animateMarkerTo(LatLng target) {
    final from = _lastAnimatedTarget;
    _lastAnimatedTarget = target;
    if (from == null || from == target) {
      _markerAnimation = null;
      return;
    }
    _markerAnimation = LatLngTween(
      begin: from,
      end: target,
    ).animate(
      CurvedAnimation(parent: _markerAnimationController, curve: Curves.easeInOut),
    );
    _markerAnimationController
      ..stop()
      ..reset()
      ..forward();
  }

  @override
  void didUpdateWidget(covariant KZLiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPolyline(widget.tracking.encodedPolyline);
    final location = widget.tracking.location;
    if (location != null && !_hasFramedCamera && _controller != null) {
      _frameCamera(location);
    }
    final oldLocation = oldWidget.tracking.location;
    if (location != null &&
        (oldLocation == null ||
            oldLocation.latitude != location.latitude ||
            oldLocation.longitude != location.longitude)) {
      _animateMarkerTo(LatLng(location.latitude, location.longitude));
    }
  }

  void _frameCamera(TrackingLocationSample driverLocation) {
    _hasFramedCamera = true;
    final controller = _controller;
    if (controller == null) return;
    if (_hasDestination) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          driverLocation.latitude < widget.destinationLat!
              ? driverLocation.latitude
              : widget.destinationLat!,
          driverLocation.longitude < widget.destinationLng!
              ? driverLocation.longitude
              : widget.destinationLng!,
        ),
        northeast: LatLng(
          driverLocation.latitude > widget.destinationLat!
              ? driverLocation.latitude
              : widget.destinationLat!,
          driverLocation.longitude > widget.destinationLng!
              ? driverLocation.longitude
              : widget.destinationLng!,
        ),
      );
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } else {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(driverLocation.latitude, driverLocation.longitude),
          15,
        ),
      );
    }
  }

  void _recenter() {
    final location = widget.tracking.location;
    if (location == null) return;
    _hasFramedCamera = false;
    _frameCamera(location);
  }

  String _ageLabel(TrackingLocationSample location) {
    final ageSeconds = DateTime.now().difference(location.receivedAt).inSeconds;
    if (ageSeconds < 5) return 'tracking.live_updated_now'.tr();
    if (ageSeconds < 60) {
      return 'tracking.live_updated_seconds_ago'.tr(
        namedArgs: {'seconds': '$ageSeconds'},
      );
    }
    final minutes = ageSeconds ~/ 60;
    return 'tracking.live_updated_minutes_ago'.tr(
      namedArgs: {'minutes': '$minutes'},
    );
  }

  /// Ages the display into "stale" purely from the local clock, independent
  /// of the backend's own `state` — a poll that keeps failing must still
  /// eventually stop looking live.
  bool _isLocallyStale(TrackingLocationSample location) {
    return DateTime.now().difference(location.receivedAt).inSeconds >
        kTrackingFreshnessThresholdSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final tracking = widget.tracking;

    switch (tracking.state) {
      case TrackingState.notStarted:
        return const SizedBox.shrink();
      case TrackingState.ended:
        return const SizedBox.shrink();
      case TrackingState.unknown:
        return const SizedBox.shrink();
      case TrackingState.waitingForLocation:
        return _buildWaiting(context);
      case TrackingState.active:
      case TrackingState.stale:
        final location = tracking.location;
        if (location == null) return _buildWaiting(context);
        return _buildMap(context, location);
    }
  }

  Widget _buildWaiting(BuildContext context) {
    final tracking = widget.tracking;
    final hasDriverInfo =
        (tracking.driverName != null && tracking.driverName!.trim().isNotEmpty) ||
        (tracking.driverPhone != null && tracking.driverPhone!.trim().isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KZ.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDriverInfo) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    tracking.driverName ?? '',
                    style: KZ.bodySmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (tracking.driverPhone != null &&
                    tracking.driverPhone!.trim().isNotEmpty)
                  TextButton.icon(
                    onPressed: () => launchPhoneCall(tracking.driverPhone!),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: Text('tracking.call_driver'.tr()),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: KZ.primary),
          ),
          const SizedBox(height: 10),
          Text(
            'tracking.live_waiting_driver'.tr(),
            style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String? _etaLabel(int? etaSeconds) {
    if (etaSeconds == null || etaSeconds <= 0) return null;
    final minutes = (etaSeconds / 60).round().clamp(1, 999);
    return 'tracking.live_eta_arriving'.tr(namedArgs: {'minutes': '$minutes'});
  }

  String? _distanceLabel(double? distanceKm) {
    if (distanceKm == null || distanceKm < 0) return null;
    return 'tracking.live_distance_away'.tr(
      namedArgs: {'distance': distanceKm.toStringAsFixed(1)},
    );
  }

  Widget _buildMap(BuildContext context, TrackingLocationSample location) {
    final tracking = widget.tracking;
    final isStale =
        _isLocallyStale(location) || tracking.state == TrackingState.stale;
    final rawTarget = LatLng(location.latitude, location.longitude);
    final distanceLabel = _distanceLabel(tracking.distanceKm);
    final etaLabel = _etaLabel(tracking.etaSeconds);

    return AnimatedBuilder(
      animation: _markerAnimationController,
      builder: (context, _) {
        final animatedTarget = _markerAnimation?.value ?? rawTarget;
        final markers = <Marker>{
          Marker(
            markerId: const MarkerId('driver'),
            position: animatedTarget,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isStale ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure,
            ),
            rotation: location.headingDegrees ?? 0,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            zIndex: 2,
          ),
          if (_hasDestination)
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(widget.destinationLat!, widget.destinationLng!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              zIndex: 1,
            ),
        };
        final polylines = <Polyline>{
          if (_polylinePoints.length >= 2)
            Polyline(
              polylineId: const PolylineId('route'),
              points: _polylinePoints,
              color: KZ.primary,
              width: 4,
              geodesic: true,
            ),
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: rawTarget,
                        zoom: 15,
                      ),
                      markers: markers,
                      polylines: polylines,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (controller) {
                        _controller = controller;
                        if (!_hasFramedCamera) _frameCamera(location);
                      },
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _RecenterButton(onPressed: _recenter),
                    ),
                    if (isStale)
                      Positioned(left: 8, top: 8, child: _StaleBadge()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (distanceLabel != null || etaLabel != null) ...[
              Row(
                children: [
                  if (distanceLabel != null) ...[
                    const Icon(
                      Icons.social_distance_rounded,
                      size: 14,
                      color: KZ.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(distanceLabel, style: KZ.caption),
                  ],
                  if (distanceLabel != null && etaLabel != null)
                    const SizedBox(width: 12),
                  if (etaLabel != null) ...[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: KZ.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(etaLabel, style: KZ.caption),
                  ],
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                Icon(
                  isStale ? Icons.warning_amber_rounded : Icons.circle,
                  size: isStale ? 16 : 8,
                  color: isStale ? KZ.error : KZ.tertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _ageLabel(location),
                    style: KZ.caption.copyWith(
                      color: isStale ? KZ.error : KZ.onSurfaceVariant,
                    ),
                  ),
                ),
                if (tracking.driverPhone != null &&
                    tracking.driverPhone!.trim().isNotEmpty)
                  TextButton.icon(
                    onPressed: () => launchPhoneCall(tracking.driverPhone!),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: Text(
                      tracking.driverName ?? 'tracking.call_driver'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// A [Tween] over [LatLng] — plain linear interpolation between two points,
/// which is a fine approximation for the short hops between consecutive
/// ~5-10s GPS fixes this animates (not meant to follow the actual road
/// path; the polyline already does that).
class LatLngTween extends Tween<LatLng> {
  LatLngTween({required super.begin, required super.end});

  @override
  LatLng lerp(double t) {
    final b = begin!;
    final e = end!;
    return LatLng(
      b.latitude + (e.latitude - b.latitude) * t,
      b.longitude + (e.longitude - b.longitude) * t,
    );
  }
}

class _RecenterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RecenterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.my_location_rounded, size: 20, color: KZ.primary),
        ),
      ),
    );
  }
}

class _StaleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KZ.error.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'tracking.live_stale_badge'.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
