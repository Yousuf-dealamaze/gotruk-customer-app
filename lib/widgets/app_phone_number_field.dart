import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AppPhoneNumberField extends StatefulWidget {
  const AppPhoneNumberField({
    super.key,
    required this.controller,
    this.hintText = 'Phone',
    this.validator,
    this.initialIsoCode = 'IN',
    this.onCountryCodeChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String initialIsoCode;
  final ValueChanged<String>? onCountryCodeChanged;

  @override
  State<AppPhoneNumberField> createState() => _AppPhoneNumberFieldState();
}

class _AppPhoneNumberFieldState extends State<AppPhoneNumberField> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {
        final parsed = number.phoneNumber ?? '';
        final dialCode = number.dialCode ?? '';
        if (dialCode.isNotEmpty) {
          widget.onCountryCodeChanged?.call(dialCode);
        }
        if (widget.controller.text != parsed) {
          widget.controller.value = TextEditingValue(
            text: parsed,
            selection: TextSelection.collapsed(offset: parsed.length),
          );
        }
      },
      selectorConfig: SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        setSelectorButtonAsPrefixIcon: true,
        leadingPadding: 12,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      initialValue: PhoneNumber(isoCode: widget.initialIsoCode),
      textFieldController: _inputController,
      formatInput: true,
      keyboardType: TextInputType.phone,
      validator: widget.validator,
      textStyle: TextStyle(color: fontBlack),
      selectorTextStyle: TextStyle(color: fontBlack),
      inputDecoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: greyFont),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: shadowColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: shadowColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}
