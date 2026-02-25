import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/router/app_router.dart';
import 'package:gotruck_customer/screens/home/home_provider.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/address_confirmation_screen.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/map_route_picker_screen.dart';
import 'package:gotruck_customer/widgets/app_text_field.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({required this.userName, required this.onLogout, super.key});

  final String userName;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  String _pickupPoint = 'Tap to choose on map';
  String _dropPoint = 'Tap to choose on map';
  DateTime? _selectedDate;
  LocationDetails? _sourceDetails;
  LocationDetails? _destinationDetails;
  double _distanceKm = 0;
  final TextEditingController _vehicleQuantityController =
      TextEditingController();

  Future<void> _openRoutePicker() async {
    final result = await Navigator.of(context).push<MapSelectionResult>(
      MaterialPageRoute(
        builder: (_) => MapRoutePickerScreen(
          initialSource: _sourceDetails?.position,
          initialDestination: _destinationDetails?.position,
        ),
      ),
    );
    if (result == null) {
      return;
    }

    setState(() {
      _sourceDetails = result.source;
      _destinationDetails = result.destination;
      _distanceKm = result.distanceKm ?? 15.75;
      _pickupPoint = _formatLocation(result.source);
      _dropPoint = _formatLocation(result.destination);
    });

    await _fetchTrucksForSelection();
  }

  String _formatLocation(LocationDetails details) {
    final label = [
      details.city,
      details.state,
      details.country,
    ].where((value) => value.trim().isNotEmpty).join(', ');
    if (label.isNotEmpty) {
      return label;
    }
    return '${details.position.latitude.toStringAsFixed(5)}, '
        '${details.position.longitude.toStringAsFixed(5)}';
  }

  Future<void> _selectPricing() async {
    await ref.read(homeProvider.notifier).getTrucks({
      "page": 1,
      "limit": 10,
      "search": "",
      "status": "active",
      "ruleTypeId": "",
      "bookingTypeId": "",
      "vehicleCategory": "",
      "vehicleTypeId": "",
      "vehicleSizeId": "",
      "cargoTypeId": "",
      "fleetId": "",
      "distanceKm": _distanceKm,
      "vehicleQty": _vehicleQuantityController.text,
      "sourceCity": _sourceDetails?.city ?? "",
      "sourceState": _sourceDetails?.state ?? "",
      "sourceCountry": _sourceDetails?.country ?? "",
      "destinationCity": _destinationDetails?.city ?? "",
      "destinationState": _destinationDetails?.state ?? "",
      "destinationCountry": _destinationDetails?.country ?? "",
    });

    if (!mounted) {
      return;
    }

    AppRouter.push(
      '/pricing-selection',
      extra: {
        "sourceDetails": _sourceDetails,
        "destinationDetails": _destinationDetails,
        "distanceKm": _distanceKm,
        "vehicleQuantity": _vehicleQuantityController.text,
        "scheduledAt": _selectedDate,
        "bookingMode": _selectedDate == DateTime.now()
            ? "Instant"
            : "Scheduled",
      },
    );
  }

  Future<void> _fetchTrucksForSelection() async {
    if (_sourceDetails == null || _destinationDetails == null) {
      return;
    }

    final payload = {
      "page": 1,
      "limit": 10,
      "search": "",
      "status": "active",
      "ruleTypeId": "",
      "bookingTypeId": "",
      "vehicleCategory": "",
      "vehicleTypeId": "",
      "vehicleSizeId": "",
      "cargoTypeId": "",
      "fleetId": "",
      "distanceKm": _distanceKm,
      "vehicleQty": 1,
      "sourceCity": _sourceDetails?.city ?? "",
      "sourceState": _sourceDetails?.state ?? "",
      "sourceCountry": _sourceDetails?.country ?? "",
      "destinationCity": _destinationDetails?.city ?? "",
      "destinationState": _destinationDetails?.state ?? "",
      "destinationCountry": _destinationDetails?.country ?? "",
    };

    await ref.read(homeProvider.notifier).getTrucks(payload);
  }

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate == null) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : TimeOfDay.fromDateTime(now),
    );
    if (pickedTime == null) {
      return;
    }

    final picked = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _selectedDate = picked;
    });
  }

  String get _dateLabel {
    if (_selectedDate == null) {
      return 'Tap to select date & time';
    }
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    final month = _selectedDate!.month.toString().padLeft(2, '0');
    final hour24 = _selectedDate!.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = _selectedDate!.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    return '$day-$month-${_selectedDate!.year} $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello.',
                      style: TextStyle(
                        color: fontBlack,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${widget.userName} 👋',
                      style: TextStyle(
                        color: fontBlack,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: shadowColor),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: greyFont,
                    size: 18,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    widget.onLogout();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _InfoTile(
                  label: 'Pickup point',
                  value: _pickupPoint,
                  icon: Icons.location_on_outlined,
                  onTap: _openRoutePicker,
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  label: 'Drop point',
                  value: _dropPoint,
                  icon: Icons.location_on_outlined,
                  onTap: _openRoutePicker,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Date',
                        value: _dateLabel,
                        icon: Icons.calendar_today_outlined,
                        onTap: _openDatePicker,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        controller: _vehicleQuantityController,
                        hintText: 'Vehicle Quantity',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.local_shipping_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vehicle Quantity is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_sourceDetails == null ||
                          _destinationDetails == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please choose pickup and drop points',
                            ),
                          ),
                        );
                        return;
                      }

                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select date and time'),
                          ),
                        );
                        return;
                      }

                      final vehicleQuantity = int.tryParse(
                        _vehicleQuantityController.text,
                      );
                      if (vehicleQuantity == null || vehicleQuantity <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid vehicle quantity',
                            ),
                          ),
                        );
                        return;
                      }

                      final confirmed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => AddressConfirmationScreen(
                            pickupPoint: _pickupPoint,
                            dropPoint: _dropPoint,
                            sourceDetails: _sourceDetails!,
                            destinationDetails: _destinationDetails!,
                            onSubmit: _selectPricing,
                          ),
                        ),
                      );

                      if (confirmed != true) {
                        return;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: cardColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Popular trucks',
                style: TextStyle(
                  color: fontBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('View all', style: TextStyle(color: greyFont)),
              ),
            ],
          ),
          const _TruckCard(),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: shadowColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: greyFont),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: greyFont, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fontBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.map_outlined, size: 16, color: greyFont),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  const _TruckCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: shadowColor),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cargo connect',
                  style: TextStyle(
                    color: fontBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: greyFont),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(
                child: _TripTime(label: 'Pick-Up', value: '10:00AM - 12:00PM'),
              ),
              Expanded(
                child: _TripTime(label: 'Drop OFF', value: '2:00PM - 4:00PM'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripTime extends StatelessWidget {
  const _TripTime({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: greyFont, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: fontBlack,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
