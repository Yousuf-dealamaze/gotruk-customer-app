import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gotruck_customer/models/pricing_response_model.dart';
import 'package:gotruck_customer/router/app_router.dart';
import 'package:gotruck_customer/screens/home/home_provider.dart';
import 'package:gotruck_customer/screens/booking/map_route_picker_screen.dart';
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
  String? _selectedRuleTypeId;
  String? _selectedBookingTypeId;
  String? _selectedVehicleCategory;
  String? _selectedVehicleTypeId;
  String? _selectedVehicleSizeId;
  String? _selectedCargoTypeId;

  PricingRow? _selectedRow(List<PricingRow> rows) {
    final id = selectedId;
    if (id == null) return null;
    for (final row in rows) {
      if (row.id == id) return row;
    }
    return null;
  }

  bool get _hasAnyFilterApplied =>
      _selectedRuleTypeId != null ||
      _selectedBookingTypeId != null ||
      _selectedVehicleCategory != null ||
      _selectedVehicleTypeId != null ||
      _selectedVehicleSizeId != null ||
      _selectedCargoTypeId != null;

  bool _matchesFilters(PricingRow row) {
    return (_selectedRuleTypeId == null || row.ruleTypeId == _selectedRuleTypeId) &&
        (_selectedBookingTypeId == null ||
            row.bookingTypeId == _selectedBookingTypeId) &&
        (_selectedVehicleCategory == null ||
            row.vehicleCategory == _selectedVehicleCategory) &&
        (_selectedVehicleTypeId == null ||
            row.vehicleTypeId == _selectedVehicleTypeId) &&
        (_selectedVehicleSizeId == null ||
            row.vehicleSizeId == _selectedVehicleSizeId) &&
        (_selectedCargoTypeId == null || row.cargoTypeId == _selectedCargoTypeId);
  }

  String _formatSlot(DateTime dateTime) {
    final hour24 = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute$period';
  }

  void _showDetailsSheet(PricingRow row) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.pricingRuleTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _DetailRow(label: "Transporter", value: row.transporterDetails.displayName),
                _DetailRow(label: "Vehicle category", value: row.vehicleCategory),
                _DetailRow(label: "Vehicle type", value: row.vehicleTypeId),
                _DetailRow(label: "Vehicle size", value: row.vehicleSizeId),
                _DetailRow(label: "Cargo type", value: row.cargoTypeId),
                _DetailRow(label: "Booking type", value: row.bookingTypeId),
                _DetailRow(label: "Rule type", value: row.ruleTypeId),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFilterBottomSheet(UniqueFilters filters) async {
    String? tempRuleTypeId = _selectedRuleTypeId;
    String? tempBookingTypeId = _selectedBookingTypeId;
    String? tempVehicleCategory = _selectedVehicleCategory;
    String? tempVehicleTypeId = _selectedVehicleTypeId;
    String? tempVehicleSizeId = _selectedVehicleSizeId;
    String? tempCargoTypeId = _selectedCargoTypeId;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Sort by",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      _FilterSection(
                        title: "Rule Type",
                        values: filters.ruleTypeId,
                        selectedValue: tempRuleTypeId,
                        onSelected: (value) {
                          setSheetState(() {
                            tempRuleTypeId = value;
                          });
                        },
                      ),
                      _FilterSection(
                        title: "Booking Type",
                        values: filters.bookingTypeId,
                        selectedValue: tempBookingTypeId,
                        onSelected: (value) {
                          setSheetState(() {
                            tempBookingTypeId = value;
                          });
                        },
                      ),
                      _FilterSection(
                        title: "Vehicle Category",
                        values: filters.vehicleCategory,
                        selectedValue: tempVehicleCategory,
                        onSelected: (value) {
                          setSheetState(() {
                            tempVehicleCategory = value;
                          });
                        },
                      ),
                      _FilterSection(
                        title: "Vehicle Type",
                        values: filters.vehicleTypeId,
                        selectedValue: tempVehicleTypeId,
                        onSelected: (value) {
                          setSheetState(() {
                            tempVehicleTypeId = value;
                          });
                        },
                      ),
                      _FilterSection(
                        title: "Vehicle Size",
                        values: filters.vehicleSizeId,
                        selectedValue: tempVehicleSizeId,
                        onSelected: (value) {
                          setSheetState(() {
                            tempVehicleSizeId = value;
                          });
                        },
                      ),
                      _FilterSection(
                        title: "Cargo Type",
                        values: filters.cargoTypeId,
                        selectedValue: tempCargoTypeId,
                        onSelected: (value) {
                          setSheetState(() {
                            tempCargoTypeId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedRuleTypeId = null;
                                  _selectedBookingTypeId = null;
                                  _selectedVehicleCategory = null;
                                  _selectedVehicleTypeId = null;
                                  _selectedVehicleSizeId = null;
                                  _selectedCargoTypeId = null;
                                  selectedId = null;
                                });
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: const Color(0xFF1B6EF3),
                                side: const BorderSide(color: Color(0xFF1B6EF3)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Clear filter"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedRuleTypeId = tempRuleTypeId;
                                  _selectedBookingTypeId = tempBookingTypeId;
                                  _selectedVehicleCategory = tempVehicleCategory;
                                  _selectedVehicleTypeId = tempVehicleTypeId;
                                  _selectedVehicleSizeId = tempVehicleSizeId;
                                  _selectedCargoTypeId = tempCargoTypeId;
                                  if (selectedId != null) {
                                    final allRows =
                                        ref.read(homeProvider).pricingResponse?.data.rows ??
                                        <PricingRow>[];
                                    final stillVisible = allRows.any((row) =>
                                        row.id == selectedId && _matchesFilters(row));
                                    if (!stillVisible) {
                                      selectedId = null;
                                    }
                                  }
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B6EF3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Apply"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final response = state.pricingResponse;
    final allRows = response?.data.rows ?? <PricingRow>[];
    final filters = response?.data.uniqueFilters;
    final rows = allRows.where(_matchesFilters).toList();
    final selectedRow = _selectedRow(rows);
    final pickupSlot = _formatSlot(widget.scheduledAt);
    final dropOffSlot = _formatSlot(widget.scheduledAt.add(const Duration(hours: 2)));


    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular trucks"),
        centerTitle: true,
        actions: [
          if (filters != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => _openFilterBottomSheet(filters),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.tune_rounded),
                    if (_hasAnyFilterApplied)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: rows.isEmpty
          ? Center(
              child: Text(
                _hasAnyFilterApplied
                    ? "No Pricing Options Found for selected filters"
                    : "No Pricing Options Found",
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ...rows.map((item) {
                  final isSelected = selectedId == item.id;
                  return _PricingCard(
                    row: item,
                    isSelected: isSelected,
                    pickupLabel: widget.sourceDetails.address,
                    dropOffLabel: widget.destinationDetails.address,
                    pickupSlot: pickupSlot,
                    dropOffSlot: dropOffSlot,
                    onDetailsTap: () => _showDetailsSheet(item),
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
              : () {
                  AppRouter.push(
                    '/payment-selection',
                    extra: {
                      "selectedPricing": selected,
                      "bookingMode": widget.bookingMode,
                      "scheduledAt": widget.scheduledAt,
                    },
                  );
                },
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> values;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const _FilterSection({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((value) {
              final isSelected = value == selectedValue;
              return ChoiceChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (_) => onSelected(isSelected ? null : value),
                selectedColor: const Color(0xFF1B6EF3),
                backgroundColor: const Color(0xFFF3F4F8),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2F2F2F),
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF1B6EF3) : Colors.transparent,
                  ),
                ),
                showCheckmark: false,
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
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
  final VoidCallback onDetailsTap;
  final String pickupLabel;
  final String dropOffLabel;
  final String pickupSlot;
  final String dropOffSlot;

  const _PricingCard({
    required this.row,
    required this.isSelected,
    required this.onTap,
    required this.onDetailsTap,
    required this.pickupLabel,
    required this.dropOffLabel,
    required this.pickupSlot,
    required this.dropOffSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF1B6EF3)
              : const Color(0xFFE8EAF0),
          width: 1.4,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFF0F4FF),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.transporterDetails.displayName.isEmpty
                          ? row.pricingRuleTitle
                          : row.transporterDetails.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SlotInfo(
                      title: "Pick-Up",
                      location: pickupLabel,
                      slot: pickupSlot,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SlotInfo(
                      title: "Drop Off",
                      location: dropOffLabel,
                      slot: dropOffSlot,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDetailsTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(36),
                        side: const BorderSide(color: Color(0xFF1B6EF3)),
                        foregroundColor: const Color(0xFF1B6EF3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Details"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(36),
                        backgroundColor: const Color(0xFF1B6EF3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Book now"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
              if (isSelected) ...[
                const SizedBox(height: 4),
                const Text(
                  "Selected for booking",
                  style: TextStyle(
                    color: Color(0xFF1B6EF3),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotInfo extends StatelessWidget {
  final String title;
  final String location;
  final String slot;

  const _SlotInfo({
    required this.title,
    required this.location,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          slot,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
