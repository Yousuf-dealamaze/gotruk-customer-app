import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gotruck_customer/constants/booking_status.dart';
import 'package:gotruck_customer/models/pricing_response_model.dart';
import 'package:gotruck_customer/router/app_router.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/booking_provider.dart';
import 'package:gotruck_customer/screens/home/home_provider.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/map_route_picker_screen.dart';
import 'package:gotruck_customer/widgets/app_button.dart';

class PricingSelectionPage extends ConsumerStatefulWidget {
  final LocationDetails sourceDetails;
  final LocationDetails destinationDetails;
  final double distanceKm;
  final String vehicleQuantity;
  final DateTime scheduledAt;
  final String bookingMode;

  const PricingSelectionPage({
    required this.sourceDetails,
    required this.destinationDetails,
    required this.distanceKm,
    required this.vehicleQuantity,
    required this.scheduledAt,
    required this.bookingMode,
    super.key,
  });

  @override
  ConsumerState<PricingSelectionPage> createState() =>
      _PricingSelectionPageState();
}

class _PricingSelectionPageState extends ConsumerState<PricingSelectionPage> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    final rows = state.pricingResponse?.data.rows ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Pricing Option"),
        centerTitle: true,
      ),
      body: rows.isEmpty
          ? const Center(child: Text("No Pricing Options Found"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final item = rows[index];
                final isSelected = selectedId == item.id;

                return _PricingCard(
                  row: item,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedId = item.id;
                    });
                  },
                );
              },
            ),
      bottomNavigationBar: _buildBottomBar(rows),
    );
  }

  /// Bottom Confirm Button
  Widget _buildBottomBar(List<PricingRow> rows) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AppButton(
          text: "Confirm Selection",
          onPressed: selectedId == null
              ? null
              : () async {
                  final selected = rows.firstWhere((e) => e.id == selectedId);
                  final response = await ref
                      .read(bookingFormProvider.notifier)
                      .createBooking({
                        "userId": ref.read(authProvider).profileData?.id,
                        // "currency": selected.currency.currencyCode,
                        "bookingDistanceKm":
                            selected.calculation.totalDistanceKm,
                        "bookingAmount": selected.calculation.totalAmount,
                        "totalDistanceKm": selected.calculation.totalDistanceKm,
                        "totalAmount": selected.calculation.totalAmount,
                        "vehiclesQuantity": selected.calculation.vehicleQty,
                        "status": OrderStatus.created.value,
                        "pricingRuleId": selected.id,
                        "booking_mode": widget.bookingMode,
                        "scheduled_at": widget.scheduledAt.toIso8601String(),
                      });
                  debugPrint("response: $response");
                  if (response) {
                    AppRouter.push('/home/bookings');
                  }
                },
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final PricingRow row;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingCard({
    required this.row,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade100,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              /// Radio Icon
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),

              const SizedBox(width: 12),

              /// Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      row.pricingRuleTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Vehicle
                    Text(
                      "Vehicle Category: ${row.vehicleCategory} ",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Vehicle Type: ${row.vehicleTypeId} ",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Vehicle Size: ${row.vehicleSizeId} ",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Cargo Type: ${row.cargoTypeId}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      "Rule Type: ${row.ruleTypeId}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      "Booking Type: ${row.bookingTypeId}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Price
                    Text(
                      "${row.currency.currencyCode} "
                      "${row.calculation.totalAmount.toStringAsFixed(2)}",
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        textStyle: const TextStyle(
                          fontFamilyFallback: ['NotoSans', 'Roboto'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
