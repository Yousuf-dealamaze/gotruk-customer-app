import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/constants/booking_status.dart';
import 'package:gotruck_customer/models/pricing_response_model.dart';
import 'package:gotruck_customer/router/app_router.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/screens/booking/booking_provider.dart';
import 'package:gotruck_customer/widgets/app_button.dart';
import 'package:gotruck_customer/widgets/custom_snackbar.dart';

class PaymentOptionScreen extends ConsumerStatefulWidget {
  const PaymentOptionScreen({
    required this.selectedPricing,
    required this.scheduledAt,
    required this.bookingMode,
    super.key,
  });

  final PricingRow selectedPricing;
  final DateTime scheduledAt;
  final String bookingMode;

  @override
  ConsumerState<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends ConsumerState<PaymentOptionScreen> {
  bool _isSubmitting = false;

  Future<void> _payNow() async {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    final pricing = widget.selectedPricing;
    final response = await ref.read(bookingFormProvider.notifier).createBooking({
      "userId": ref.read(authProvider).profileData?.id,
      "bookingDistanceKm": pricing.calculation.totalDistanceKm,
      "bookingAmount": pricing.calculation.totalAmount,
      "totalDistanceKm": pricing.calculation.totalDistanceKm,
      "totalAmount": pricing.calculation.totalAmount,
      "vehiclesQuantity": pricing.calculation.vehicleQty,
      "status": OrderStatus.created.value,
      "pricingRuleId": pricing.id,
      "booking_mode": widget.bookingMode,
      "scheduled_at": widget.scheduledAt.toIso8601String(),
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!response) {
      CustomSnackbar.show(message: "Booking failed, please try again.");
      return;
    }

    AppRouter.go('/booking-success');
  }

  @override
  Widget build(BuildContext context) {
    final pricing = widget.selectedPricing;
    final amount = pricing.calculation.totalAmount.toStringAsFixed(2);
    final currencyCode = pricing.currency.currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment method'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              children: [
                Text(
                  'Select payment method',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    onTap: () {},
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text(
                      'Cash on Delivery (COD)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(
                      Icons.radio_button_checked,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$currencyCode $amount',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      text: 'Pay now',
                      isLoading: _isSubmitting,
                      onPressed: _payNow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
