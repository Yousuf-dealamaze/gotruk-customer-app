import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/models/booking_model.dart';
import 'package:gotruck_customer/screens/home/home_provider.dart';

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
      return const Center(child: CircularProgressIndicator());
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

    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          'Bookings',
          style: TextStyle(
            color: fontBlack,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingCard(booking: booking);
            },
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingRow booking;

  @override
  Widget build(BuildContext context) {
    final createdDate =
        '${booking.createdAt.day.toString().padLeft(2, '0')}-'
        '${booking.createdAt.month.toString().padLeft(2, '0')}-'
        '${booking.createdAt.year}';

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

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: shadowColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.bookingCode.isNotEmpty
                      ? booking.bookingCode
                      : booking.id,
                  style: TextStyle(
                    color: fontBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              _StatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Fleet',
            value: booking.pricingRule.fleet.name.isNotEmpty
                ? booking.pricingRule.fleet.name
                : '-',
          ),
          _InfoRow(
            label: 'Distance',
            value: '${booking.totalDistanceKm.toStringAsFixed(2)} km',
          ),
          _InfoRow(
            label: 'Amount',
            value:
                '${booking.pricingRule.dayFixCurrency} ${booking.totalAmount.toStringAsFixed(2)}',
          ),
          _InfoRow(label: 'Date', value: createdDate),
          const Divider(height: 18),
          _InfoRow(label: 'Pickup', value: pickupAddress),
          const SizedBox(height: 4),
          _InfoRow(label: 'Drop', value: dropAddress),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: greyFont, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: fontBlack,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final Color color = normalized == 'completed'
        ? Colors.green
        : normalized == 'cancelled'
        ? Colors.red
        : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
