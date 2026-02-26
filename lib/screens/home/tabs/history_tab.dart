import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/models/booking_model.dart';
import 'package:gotruck_customer/screens/home/home_provider.dart';
import 'package:gotruck_customer/screens/home/history_booking_detail_page.dart';

class HistoryTab extends ConsumerStatefulWidget {
  const HistoryTab({super.key});

  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).getBookings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final bookings = state.bookingResponse?.data.rows ?? const <BookingRow>[];

    if (state.bookingResponse == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: shadowColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined, size: 40, color: primaryColor),
              const SizedBox(height: 10),
              Text(
                'No trip history yet',
                style: TextStyle(
                  color: fontBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Completed bookings will appear here.',
                style: TextStyle(color: greyFont),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Bookings',
              style: TextStyle(
                color: fontBlack,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingCard(booking: booking);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

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

    final baseTime = booking.scheduledAt ?? booking.createdAt;
    final pickupTime = _formatTime(baseTime);
    final dropTime = _formatTime(baseTime.add(const Duration(hours: 2)));
    final title = booking.pricingRule.fleet.name.isNotEmpty
        ? booking.pricingRule.fleet.name
        : (booking.bookingCode.isNotEmpty ? booking.bookingCode : 'Booking');

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_shipping_rounded, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: fontBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScheduleRow(
            label: 'Pick-Up',
            time: '$pickupTime',
            details: pickupAddress,
          ),
          const SizedBox(height: 8),
          _ScheduleRow(
            label: 'Drop Off',
            time: '$dropTime',
            details: dropAddress,
          ),
          const SizedBox(height: 12),
          Text(
            '${booking.pricingRule.dayFixCurrency} ${booking.totalAmount.toStringAsFixed(2)} • ${booking.totalDistanceKm.toStringAsFixed(1)} km',
            style: TextStyle(
              color: greyFont,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoryBookingDetailPage(booking: booking),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text(
                    'Details',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.label,
    required this.time,
    required this.details,
  });

  final String label;
  final String time;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: greyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                time,
                style: TextStyle(
                  color: fontBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: greyFont.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute$period';
}
