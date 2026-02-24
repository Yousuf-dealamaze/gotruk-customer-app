import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.options,
    this.prefixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final List<String> options;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedValue = options.contains(controller.text)
        ? controller.text
        : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options
          .map(
            (option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)),
          )
          .toList(),
      onChanged: (value) {
        controller.text = value ?? '';
      },
      validator: validator,
      style: TextStyle(color: fontBlack),
      icon: Icon(Icons.keyboard_arrow_down, color: greyFont),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: greyFont),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: greyFont),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
