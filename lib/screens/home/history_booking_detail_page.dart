import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/models/booking_model.dart';

class HistoryBookingDetailPage extends StatelessWidget {
  const HistoryBookingDetailPage({super.key, required this.booking});

  final BookingRow booking;

  @override
  Widget build(BuildContext context) {
    final pickupAddress = booking.addresses.pickup is Map<String, dynamic>
        ? (booking.addresses.pickup['addressLine1'] ??
                  booking.addresses.pickup['city'] ??
                  'Pickup not available')
              .toString()
        : 'Pickup not available';

    final dropAddress = booking.addresses.drop is Map<String, dynamic>
        ? (booking.addresses.drop['addressLine1'] ??
                  booking.addresses.drop['city'] ??
                  'Drop not available')
              .toString()
        : 'Drop not available';

    final scheduled = booking.scheduledAt ?? booking.createdAt;
    final completedOrBookedAt = _formatDate(booking.updatedAt);
    final amount =
        '${booking.pricingRule.dayFixCurrency} ${booking.totalAmount.toStringAsFixed(2)}';
    final loadingCapacity = booking.pricingRule.fleet.capacity.weight.isNotEmpty
        ? booking.pricingRule.fleet.capacity.weight
        : '-';
    final truckSize = booking.pricingRule.vehicleSizeId.isNotEmpty
        ? booking.pricingRule.vehicleSizeId
        : '-';
    final truckType = booking.pricingRule.vehicleCategory.isNotEmpty
        ? booking.pricingRule.vehicleCategory
        : '-';
    final description = booking.pricingRule.pricingRuleTitle.isNotEmpty
        ? booking.pricingRule.pricingRuleTitle
        : 'This booking was previously completed and is available in your history.';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: fontBlack,
        title: Text(
          'Booking details',
          style: TextStyle(
            color: fontBlack,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4DA3FF), Color(0xFF1F6ED9)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: 22,
                    child: Icon(
                      Icons.local_shipping_rounded,
                      size: 150,
                      color: Colors.white.withValues(alpha: 0.23),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.pricingRule.fleet.name.isNotEmpty
                              ? booking.pricingRule.fleet.name
                              : 'Truck booking',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          booking.bookingCode.isNotEmpty
                              ? booking.bookingCode
                              : booking.id,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        _StatusTag(status: booking.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              child: Column(
                children: [
                  _InfoLine(label: 'Loading capacity', value: loadingCapacity),
                  _InfoLine(label: 'Type', value: truckType),
                  _InfoLine(label: 'Size', value: truckSize),
                  _InfoLine(label: 'Price', value: amount),
                  _InfoLine(
                    label: 'Distance',
                    value: '${booking.totalDistanceKm.toStringAsFixed(1)} km',
                  ),
                  _InfoLine(
                    label: 'Quantity',
                    value: '${booking.vehiclesQuantity} trucks',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip summary',
                    style: TextStyle(
                      color: fontBlack,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AddressLine(
                    icon: Icons.radio_button_checked_rounded,
                    title: 'Pick-up',
                    subtitle: '$pickupAddress • ${_formatTime(scheduled)}',
                  ),
                  const SizedBox(height: 8),
                  _AddressLine(
                    icon: Icons.location_on_rounded,
                    title: 'Drop off',
                    subtitle:
                        '$dropAddress • ${_formatTime(scheduled.add(const Duration(hours: 2)))}',
                  ),
                  const SizedBox(height: 8),
                  _AddressLine(
                    icon: Icons.calendar_today_rounded,
                    title: 'Booked at',
                    subtitle: completedOrBookedAt,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      color: fontBlack,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: greyFont,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: shadowColor),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: greyFont, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: fontBlack,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: fontBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: greyFont,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final Color bg = normalized == 'completed'
        ? const Color(0xFFDCFCE7)
        : normalized == 'cancelled'
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFDBEAFE);
    final Color fg = normalized == 'completed'
        ? const Color(0xFF166534)
        : normalized == 'cancelled'
        ? const Color(0xFF991B1B)
        : const Color(0xFF1D4ED8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isNotEmpty ? status : 'Booked',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute$period';
}
