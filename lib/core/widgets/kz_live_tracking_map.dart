import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/maps_launcher.dart';
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

class _KZLiveTrackingMapState extends State<KZLiveTrackingMap> {
  GoogleMapController? _controller;
  bool _hasFramedCamera = false;
  Timer? _ageTicker;

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
  }

  @override
  void dispose() {
    _ageTicker?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KZLiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final location = widget.tracking.location;
    if (location != null && !_hasFramedCamera && _controller != null) {
      _frameCamera(location);
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
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: KZ.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: KZ.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'tracking.live_connecting'.tr(),
              style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, TrackingLocationSample location) {
    final tracking = widget.tracking;
    final isStale =
        _isLocallyStale(location) || tracking.state == TrackingState.stale;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(location.latitude, location.longitude),
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndex: 1,
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
                    target: LatLng(location.latitude, location.longitude),
                    zoom: 15,
                  ),
                  markers: markers,
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
                if (isStale) Positioned(left: 8, top: 8, child: _StaleBadge()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
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
