import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/widgets/app_button.dart';
import 'package:gotruck_customer/widgets/app_phone_number_field.dart';
import 'package:gotruck_customer/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countryCodeController = TextEditingController(text: '+91');
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _resetToken;
  int _step = 1;

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final ok = await ref
        .read(authProvider.notifier)
        .sendOtp(
          otpType: 'phone',
          countryCode: _countryCodeController.text.trim(),
          phoneNumber: _normalizedPhoneNumber(),
        );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to send OTP. Please try again.')),
      );
      return;
    }

    setState(() => _step = 2);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP sent successfully.')));
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    final token = await ref
        .read(authProvider.notifier)
        .verifyResetOtp(
          otpType: 'phone',
          countryCode: _countryCodeController.text.trim(),
          phoneNumber: _normalizedPhoneNumber(),
          otp: otp,
        );

    if (!mounted) return;
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP verification failed.')));
      return;
    }

    setState(() {
      _step = 3;
      _resetToken = token;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP verified. Please set new password.')),
    );
  }

  String _normalizedPhoneNumber() {
    final raw = _phoneController.text.trim();
    final code = _countryCodeController.text.trim();
    if (raw.isEmpty) {
      return raw;
    }
    if (code.isEmpty) {
      return raw;
    }
    if (raw.startsWith(code)) {
      return raw.substring(code.length).trim();
    }
    return raw;
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter new password.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirm password does not match.')),
      );
      return;
    }
    final token = _resetToken ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset token missing. Verify OTP again.')),
      );
      return;
    }

    final ok = await ref
        .read(authProvider.notifier)
        .resetPassword(resetToken: token, newPassword: password);

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reset password.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successful. Please login.')),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _step == 1
                            ? 'Verify phone number'
                            : _step == 2
                            ? 'Enter OTP'
                            : 'Set new password',
                        style: textTheme.titleLarge?.copyWith(
                          color: fontBlack,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _step == 1
                            ? 'We will send OTP to your phone.'
                            : _step == 2
                            ? 'Enter the OTP sent to your phone.'
                            : 'Create a strong password for your account.',
                        style: textTheme.bodyMedium?.copyWith(color: greyFont),
                      ),
                      const SizedBox(height: 20),
                      if (_step == 1) ...[
                        AppPhoneNumberField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          initialIsoCode: 'IN',
                          onCountryCodeChanged: (dialCode) {
                            _countryCodeController.text = dialCode;
                          },
                          validator: (value) {
                            final phone = value?.trim() ?? '';
                            if (phone.isEmpty) {
                              return 'Phone number is required';
                            }
                            final digitCount = phone
                                .replaceAll(RegExp(r'\D'), '')
                                .length;
                            if (digitCount < 8) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: 'Send OTP',
                          isLoading: authState.isLoading,
                          onPressed: _sendOtp,
                        ),
                      ],
                      if (_step == 2) ...[
                        AppTextField(
                          controller: _otpController,
                          hintText: 'Enter 6-digit OTP',
                          prefixIcon: Icons.verified_user_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final otp = value?.trim() ?? '';
                            if (otp.isEmpty) {
                              return 'OTP is required';
                            }
                            if (otp.length != 6) {
                              return 'Enter valid 6-digit OTP';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: 'Verify OTP',
                          isLoading: authState.isLoadingPhone,
                          onPressed: _verifyOtp,
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _sendOtp,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                      if (_step == 3) ...[
                        AppTextField(
                          controller: _passwordController,
                          hintText: 'New Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm New Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: 'Reset Password',
                          isLoading: authState.isLoading,
                          onPressed: _resetPassword,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
