import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gotruck_customer/constants/core.dart';
import 'package:gotruck_customer/services/places_service.dart';
import 'package:gotruck_customer/core/theme/colors.dart';

/// ======================
/// MODELS
/// ======================
class LocationDetails {
  final LatLng position;
  final String address;
  final String city;
  final String state;
  final String country;

  LocationDetails({
    required this.position,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });
}

class MapSelectionResult {
  final LocationDetails source;
  final LocationDetails destination;
  final double? distanceKm;

  MapSelectionResult({
    required this.source,
    required this.destination,
    this.distanceKm,
  });
}

/// ======================
/// SCREEN
/// ======================
class MapRoutePickerScreen extends StatefulWidget {
  const MapRoutePickerScreen({
    super.key,
    this.initialSource,
    this.initialDestination,
  });

  final LatLng? initialSource;
  final LatLng? initialDestination;

  @override
  State<MapRoutePickerScreen> createState() => _MapRoutePickerScreenState();
}

class _MapRoutePickerScreenState extends State<MapRoutePickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late PlacesService _places;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _srcCtrl = TextEditingController();
  final _dstCtrl = TextEditingController();
  final _srcFocus = FocusNode();
  final _dstFocus = FocusNode();

  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];

  LatLng? _source;
  LatLng? _destination;
  String? _srcAddress;
  String? _dstAddress;

  List<LatLng> _route = [];
  double? _distance;
  String? _duration;
  bool _hasPermission = false;
  bool _isLoadingRoute = false;

  static const _defaultCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  /// ======================
  /// INIT
  /// ======================
  @override
  void initState() {
    super.initState();
    _places = PlacesService(Constant.googleMapsApiKey);
    _source = widget.initialSource;
    _destination = widget.initialDestination;

    // Animation setup
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();

    _requestPermission();
    _srcCtrl.addListener(() => _onSearch(true));
    _dstCtrl.addListener(() => _onSearch(false));
    _srcFocus.addListener(_clearSuggestions);
    _dstFocus.addListener(_clearSuggestions);
  }

  @override
  void dispose() {
    _srcCtrl.dispose();
    _dstCtrl.dispose();
    _srcFocus.dispose();
    _dstFocus.dispose();
    _debounce?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _clearSuggestions() {
    if (!_srcFocus.hasFocus && !_dstFocus.hasFocus) {
      setState(() => _suggestions.clear());
    }
  }

  /// ======================
  /// PERMISSION
  /// ======================
  Future<void> _requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() => _hasPermission = true);
    }
  }

  /// ======================
  /// AUTOCOMPLETE
  /// ======================
  void _onSearch(bool isSource) {
    final text = isSource ? _srcCtrl.text : _dstCtrl.text;
    if (text.length < 3) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _places.fetchSuggestions(text);
      if (!mounted) return;
      setState(() => _suggestions = result);
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion s, bool isSource) async {
    final detail = await _places.fetchPlaceDetails(s.placeId);
    if (detail == null) return;

    final latLng = LatLng(detail.lat, detail.lng);
    setState(() {
      if (isSource) {
        _source = latLng;
        _srcCtrl.text = detail.address;
        _srcAddress = detail.address;
        _srcFocus.unfocus();
      } else {
        _destination = latLng;
        _dstCtrl.text = detail.address;
        _dstAddress = detail.address;
        _dstFocus.unfocus();
      }
      _suggestions.clear();
      _route.clear();
      _distance = null;
      _duration = null;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

    if (_source != null && _destination != null) {
      _fetchRoute();
    }
  }

  /// ======================
  /// MAP TAP
  /// ======================
  Future<void> _onMapTap(LatLng point) async {
    final places = await placemarkFromCoordinates(
      point.latitude,
      point.longitude,
    );
    final pm = places.first;
    final address = [
      pm.name,
      pm.street,
      pm.locality,
      pm.administrativeArea,
      pm.country,
    ].whereType<String>().join(', ');

    setState(() {
      if (_source == null) {
        _source = point;
        _srcCtrl.text = address;
        _srcAddress = address;
      } else if (_destination == null) {
        _destination = point;
        _dstCtrl.text = address;
        _dstAddress = address;
      } else {
        _source = point;
        _destination = null;
        _srcCtrl.text = address;
        _dstCtrl.clear();
        _srcAddress = address;
        _dstAddress = null;
        _route.clear();
        _distance = null;
        _duration = null;
      }
      _suggestions.clear();
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(point, 15));

    if (_source != null && _destination != null) {
      _fetchRoute();
    }
  }

  /// ======================
  /// ROUTE
  /// ======================
  Future<void> _fetchRoute() async {
    setState(() => _isLoadingRoute = true);

    final poly = PolylinePoints(apiKey: Constant.googleMapsApiKey);
    final res = await poly.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(_source!.latitude, _source!.longitude),
        destination: PointLatLng(
          _destination!.latitude,
          _destination!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (res.points.isEmpty) {
      setState(() => _isLoadingRoute = false);
      return;
    }

    final pts = res.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

    setState(() {
      _route = pts;
      _distance = res.totalDistanceValue != null
          ? res.totalDistanceValue! / 1000
          : null;
      _duration = res.totalDurationValue != null
          ? _formatDuration(res.totalDurationValue!)
          : null;
      _isLoadingRoute = false;
    });

    _fitCamera();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  void _fitCamera() {
    if (_mapController == null || _source == null || _destination == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        _source!.latitude < _destination!.latitude
            ? _source!.latitude
            : _destination!.latitude,
        _source!.longitude < _destination!.longitude
            ? _source!.longitude
            : _destination!.longitude,
      ),
      northeast: LatLng(
        _source!.latitude > _destination!.latitude
            ? _source!.latitude
            : _destination!.latitude,
        _source!.longitude > _destination!.longitude
            ? _source!.longitude
            : _destination!.longitude,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  /// ======================
  /// REVERSE GEO
  /// ======================
  Future<LocationDetails> _reverseGeo(LatLng p, String? addr) async {
    final places = await placemarkFromCoordinates(p.latitude, p.longitude);
    final pm = places.first;
    return LocationDetails(
      position: p,
      address: addr ?? '',
      city: pm.locality ?? '',
      state: pm.administrativeArea ?? '',
      country: pm.country ?? '',
    );
  }

  void _swapLocations() {
    if (_source == null || _destination == null) return;

    setState(() {
      final tempPos = _source;
      final tempAddr = _srcAddress;
      final tempText = _srcCtrl.text;

      _source = _destination;
      _srcAddress = _dstAddress;
      _srcCtrl.text = _dstCtrl.text;

      _destination = tempPos;
      _dstAddress = tempAddr;
      _dstCtrl.text = tempText;

      _route.clear();
      _distance = null;
      _duration = null;
    });

    _fetchRoute();
  }

  /// ======================
  /// UI
  /// ======================
  @override
  Widget build(BuildContext context) {
    final ready = _source != null && _destination != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          /// MAP
          GoogleMap(
            initialCameraPosition: _defaultCamera,
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: _hasPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers(),
            polylines: _polylines(),
            onTap: _onMapTap,
            style: _mapStyle,
          ),

          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              children: [
                _topSearchCard(),
                if (_distance != null || _isLoadingRoute) _routeInfoCard(),
              ],
            ),
          ),
          if (_suggestions.isNotEmpty) _suggestionPanel(),

          _mapControls(),

          _confirmButton(ready),
        ],
      ),
    );
  }

  Widget _topSearchCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Material(
              elevation: 6,
              shadowColor: shadowColor,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _modernField(
                      _srcCtrl,
                      _srcFocus,
                      "Pickup location",
                      Icons.trip_origin,
                      successColor,
                      true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 36),
                          Expanded(
                            child: Container(height: 1, color: backgroundColor),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _swapLocations,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.swap_vert_rounded,
                                  color: primaryColor,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: backgroundColor),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    _modernField(
                      _dstCtrl,
                      _dstFocus,
                      "Drop location",
                      Icons.location_on,
                      const Color(0xFFFF1744),
                      false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernField(
    TextEditingController ctrl,
    FocusNode focus,
    String hint,
    IconData icon,
    Color color,
    bool isFirst,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: TextField(
        controller: ctrl,
        focusNode: focus,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: fontBlack,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: greyFont,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          suffixIcon: ctrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: greyFont, size: 18),
                  onPressed: () {
                    ctrl.clear();
                    if (isFirst) {
                      setState(() {
                        _source = null;
                        _srcAddress = null;
                        _route.clear();
                        _distance = null;
                        _duration = null;
                      });
                    } else {
                      setState(() {
                        _destination = null;
                        _dstAddress = null;
                        _route.clear();
                        _distance = null;
                        _duration = null;
                      });
                    }
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _suggestionPanel() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 90,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        shadowColor: shadowColor,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: 60, color: backgroundColor),
              itemBuilder: (_, i) {
                final s = _suggestions[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    s.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: fontBlack,
                    ),
                  ),
                  onTap: () => _selectSuggestion(s, _srcFocus.hasFocus),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeInfoCard() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      shadowColor: shadowColor,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: AppGradients.gradientPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _isLoadingRoute
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Calculating route...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _routeInfoItem(
                    Icons.straighten_rounded,
                    'Distance',
                    '${_distance!.toStringAsFixed(1)} km',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _routeInfoItem(
                    Icons.access_time_rounded,
                    'Duration',
                    _duration ?? 'N/A',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _routeInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _mapControls() {
    return Positioned(
      right: 12,
      bottom: 160,
      child: Column(
        children: [
          _mapControlButton(
            Icons.my_location_rounded,
            () async {
              if (_hasPermission && _mapController != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Location feature requires location service',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: fontBlack,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            primaryColor,
            true,
          ),
          const SizedBox(height: 10),
          _mapControlButton(
            Icons.add_rounded,
            () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            cardColor,
            false,
          ),
          const SizedBox(height: 8),
          _mapControlButton(
            Icons.remove_rounded,
            () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            cardColor,
            false,
          ),
        ],
      ),
    );
  }

  Widget _mapControlButton(
    IconData icon,
    VoidCallback onTap,
    Color bgColor,
    bool isPrimary,
  ) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      shadowColor: shadowColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : fontBlack,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _confirmButton(bool enabled) {
    return Positioned(
      bottom: 20,
      left: 12,
      right: 12,
      child: Material(
        elevation: enabled ? 8 : 4,
        borderRadius: BorderRadius.circular(16),
        shadowColor: enabled ? primaryColor.withOpacity(0.3) : shadowColor,
        child: InkWell(
          onTap: enabled
              ? () async {
                  final src = await _reverseGeo(_source!, _srcAddress);
                  final dst = await _reverseGeo(_destination!, _dstAddress);
                  if (!mounted) return;
                  Navigator.pop(
                    context,
                    MapSelectionResult(
                      source: src,
                      destination: dst,
                      distanceKm: _distance,
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: enabled
                  ? AppGradients.buttonGradientPrimary
                  : LinearGradient(
                      colors: [
                        greyFont.withOpacity(0.3),
                        greyFont.withOpacity(0.4),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  "Confirm Route",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ======================
  /// MAP STYLING
  /// ======================
  Set<Marker> _markers() {
    final m = <Marker>{};
    if (_source != null) {
      m.add(
        Marker(
          markerId: const MarkerId("src"),
          position: _source!,
          infoWindow: InfoWindow(title: "Pickup", snippet: _srcAddress),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
    if (_destination != null) {
      m.add(
        Marker(
          markerId: const MarkerId("dst"),
          position: _destination!,
          infoWindow: InfoWindow(title: "Drop-off", snippet: _dstAddress),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    return m;
  }

  Set<Polyline> _polylines() {
    if (_route.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: _route,
        width: 5,
        color: primaryColor,
        geodesic: true,
      ),
    };
  }

  static const String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';
}
