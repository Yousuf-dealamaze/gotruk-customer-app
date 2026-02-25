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
import 'package:gotruck_customer/widgets/custom_snackbar.dart';

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

  PricingRow? _selectedRow(List<PricingRow> rows) {
    final id = selectedId;
    if (id == null) return null;
    for (final row in rows) {
      if (row.id == id) return row;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    final rows = state.pricingResponse?.data.rows ?? [];
    final selectedRow = _selectedRow(rows);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Pricing Option"),
        centerTitle: true,
      ),
      body: rows.isEmpty
          ? const Center(child: Text("No Pricing Options Found"))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ...rows.map((item) {
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
                }),
                if (selectedRow != null)
                  _SelectedCalculationSection(row: selectedRow),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(selectedRow),
    );
  }

  /// Bottom Confirm Button
  Widget _buildBottomBar(PricingRow? selected) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AppButton(
          text: "Confirm Selection",
          onPressed: selected == null
              ? null
              : () async {
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
                  if (response) {
                    CustomSnackbar.show(
                      message: "Booking created successfully",
                      isSuccess: true,
                    );
                    AppRouter.push('/home/bookings');
                  }
                },
        ),
      ),
    );
  }
}

class _SelectedCalculationSection extends StatelessWidget {
  final PricingRow row;

  const _SelectedCalculationSection({required this.row});

  String _formatAmount(double value) => value.toStringAsFixed(2);
  String _formatPercent(double value) => (value * 100).toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final calc = row.calculation;
    final code = row.currency.currencyCode;
    // final symbol = row.currency.currencySymbol;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Distance Breakdown",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (calc.breakdown.isEmpty)
              const Text("No slab breakdown available")
            else
              ...calc.breakdown.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.slab)),
                      Text("${item.distanceInSlab.toStringAsFixed(2)} km"),
                      const SizedBox(width: 8),
                      Text("${_formatAmount(item.slabAmount)} $code"),
                    ],
                  ),
                ),
              ),
            const Divider(height: 20),
            Text(
              "Cost Summary",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: "Base Price x ${calc.vehicleQty} vehicle(s)",
              value: "${_formatAmount(calc.basePrice)} $code",
            ),
            _SummaryRow(
              label: "Base Price Amount",
              value: "${_formatAmount(calc.basePriceAmount)} $code",
            ),
            _SummaryRow(
              label: "Distance Amount",
              value: "${_formatAmount(calc.distanceAmount)} $code",
            ),
            _SummaryRow(
              label:
                  "Platform Charges (${_formatPercent(calc.rates.platformRate)}%)",
              value: "${_formatAmount(calc.platformCharges)} $code",
            ),
            _SummaryRow(
              label: "Gross Total",
              value: "${_formatAmount(calc.grossTotal)} $code",
              isBold: true,
            ),
            _SummaryRow(
              label:
                  "Service Tax (${_formatPercent(calc.rates.serviceTaxRate)}%)",
              value: "${_formatAmount(calc.serviceTax)} $code",
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  "${_formatAmount(calc.totalAmount)} $code",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
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
