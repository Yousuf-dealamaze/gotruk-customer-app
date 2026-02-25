import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/booking_provider.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/map_route_picker_screen.dart';

class AddressConfirmationScreen extends ConsumerStatefulWidget {
  const AddressConfirmationScreen({
    required this.pickupPoint,
    required this.dropPoint,
    required this.sourceDetails,
    required this.destinationDetails,
    required this.onSubmit,
    super.key,
  });

  final String pickupPoint;
  final String dropPoint;
  final LocationDetails sourceDetails;
  final LocationDetails destinationDetails;
  final Future<void> Function() onSubmit;
  @override
  ConsumerState<AddressConfirmationScreen> createState() =>
      _AddressConfirmationScreenState();
}

class _AddressConfirmationScreenState
    extends ConsumerState<AddressConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _SectionControllers _pickupControllers;
  late final _SectionControllers _dropControllers;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profileData;
    final existing = ref.read(bookingFormProvider);

    final defaultPhone =
        '${profile?.countryCode ?? ''}${profile?.phoneNumber ?? ''}';

    final pickupDefaults = BookingAddressFormData.fromLocationDetails(
      details: widget.sourceDetails,
      addressLine1: widget.pickupPoint,
      firstName: profile?.firstName ?? '',
      lastName: profile?.lastName ?? '',
      email: profile?.email ?? '',
      phone: defaultPhone,
    );
    final dropDefaults = BookingAddressFormData.fromLocationDetails(
      details: widget.destinationDetails,
      addressLine1: widget.dropPoint,
      firstName: profile?.firstName ?? '',
      lastName: profile?.lastName ?? '',
      email: profile?.email ?? '',
      phone: defaultPhone,
    );

    final pickupData = existing.pickupAddress.hasAnyValue
        ? existing.pickupAddress
        : pickupDefaults;
    final dropData = existing.dropAddress.hasAnyValue
        ? existing.dropAddress
        : dropDefaults;

    _pickupControllers = _SectionControllers.fromData(pickupData);
    _dropControllers = _SectionControllers.fromData(dropData);
  }

  @override
  void dispose() {
    _pickupControllers.dispose();
    _dropControllers.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref
        .read(bookingFormProvider.notifier)
        .setAddresses(
          pickupAddress: _pickupControllers.toFormData(),
          dropAddress: _dropControllers.toFormData(),
        );

    await widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Address Confirmation')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    if (isWide) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _AddressDetailsForm(
                                title: 'Pickup Details',
                                controllers: _pickupControllers,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _AddressDetailsForm(
                                title: 'Drop Details',
                                controllers: _dropControllers,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _AddressDetailsForm(
                            title: 'Pickup Details',
                            controllers: _pickupControllers,
                          ),
                          const SizedBox(height: 16),
                          _AddressDetailsForm(
                            title: 'Drop Details',
                            controllers: _dropControllers,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Edit route'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _onConfirm,
                      child: const Text('Confirm and continue'),
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

class _AddressDetailsForm extends StatelessWidget {
  const _AddressDetailsForm({required this.title, required this.controllers});

  final String title;
  final _SectionControllers controllers;

  @override
  Widget build(BuildContext context) {
    final sectionTextStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('CONTACT INFORMATION', style: sectionTextStyle),
            const SizedBox(height: 8),
            _TwoColumnFields(
              left: _FieldConfig(
                label: 'First Name',
                controller: controllers.firstName,
                validator: _requiredValidator,
              ),
              right: _FieldConfig(
                label: 'Last Name',
                controller: controllers.lastName,
                validator: _requiredValidator,
              ),
            ),
            const SizedBox(height: 8),
            _TwoColumnFields(
              left: _FieldConfig(
                label: 'Email',
                hint: 'email@example.com',
                controller: controllers.email,
                validator: _emailValidator,
              ),
              right: _FieldConfig(
                label: 'Phone',
                controller: controllers.phone,
                validator: _requiredValidator,
              ),
            ),
            const SizedBox(height: 12),
            Text('ADDRESS', style: sectionTextStyle),
            const SizedBox(height: 8),
            _InputField(
              label: 'Address Line 1',
              controller: controllers.addressLine1,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 8),
            _InputField(
              label: 'Address Line 2',
              controller: controllers.addressLine2,
            ),
            const SizedBox(height: 8),
            _InputField(
              label: 'Landmark',
              hint: 'Nearby landmark',
              controller: controllers.landmark,
            ),
            const SizedBox(height: 8),
            _TwoColumnFields(
              left: _FieldConfig(
                label: 'City',
                controller: controllers.city,
                validator: _requiredValidator,
              ),
              right: _FieldConfig(
                label: 'Postal Code',
                controller: controllers.postalCode,
              ),
            ),
            const SizedBox(height: 8),
            _TwoColumnFields(
              left: _FieldConfig(
                label: 'State / Region',
                controller: controllers.stateRegion,
                validator: _requiredValidator,
              ),
              right: _FieldConfig(
                label: 'Country',
                controller: controllers.country,
                validator: _requiredValidator,
              ),
            ),
            const SizedBox(height: 12),
            Text('GPS COORDINATES', style: sectionTextStyle),
            const SizedBox(height: 8),
            _TwoColumnFields(
              left: _FieldConfig(
                label: 'Latitude',
                controller: controllers.latitude,
                validator: _requiredValidator,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              right: _FieldConfig(
                label: 'Longitude',
                controller: controllers.longitude,
                validator: _requiredValidator,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coordinates are auto-filled from the map selection in the previous step.',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoColumnFields extends StatelessWidget {
  const _TwoColumnFields({required this.left, required this.right});

  final _FieldConfig left;
  final _FieldConfig right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InputField(
            label: left.label,
            controller: left.controller,
            hint: left.hint,
            validator: left.validator,
            keyboardType: left.keyboardType,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InputField(
            label: right.label,
            controller: right.controller,
            hint: right.hint,
            validator: right.validator,
            keyboardType: right.keyboardType,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldConfig {
  const _FieldConfig({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
}

class _SectionControllers {
  _SectionControllers({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.postalCode,
    required this.stateRegion,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController landmark;
  final TextEditingController city;
  final TextEditingController postalCode;
  final TextEditingController stateRegion;
  final TextEditingController country;
  final TextEditingController latitude;
  final TextEditingController longitude;

  factory _SectionControllers.fromData(BookingAddressFormData data) {
    return _SectionControllers(
      firstName: TextEditingController(text: data.firstName),
      lastName: TextEditingController(text: data.lastName),
      email: TextEditingController(text: data.email),
      phone: TextEditingController(text: data.phone),
      addressLine1: TextEditingController(text: data.addressLine1),
      addressLine2: TextEditingController(text: data.addressLine2),
      landmark: TextEditingController(text: data.landmark),
      city: TextEditingController(text: data.city),
      postalCode: TextEditingController(text: data.postalCode),
      stateRegion: TextEditingController(text: data.stateRegion),
      country: TextEditingController(text: data.country),
      latitude: TextEditingController(text: data.latitude),
      longitude: TextEditingController(text: data.longitude),
    );
  }

  BookingAddressFormData toFormData() {
    return BookingAddressFormData(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      email: email.text.trim(),
      phone: phone.text.trim(),
      addressLine1: addressLine1.text.trim(),
      addressLine2: addressLine2.text.trim(),
      landmark: landmark.text.trim(),
      city: city.text.trim(),
      postalCode: postalCode.text.trim(),
      stateRegion: stateRegion.text.trim(),
      country: country.text.trim(),
      latitude: latitude.text.trim(),
      longitude: longitude.text.trim(),
    );
  }

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    addressLine1.dispose();
    addressLine2.dispose();
    landmark.dispose();
    city.dispose();
    postalCode.dispose();
    stateRegion.dispose();
    country.dispose();
    latitude.dispose();
    longitude.dispose();
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  if (!value.contains('@')) {
    return 'Enter a valid email';
  }
  return null;
}
