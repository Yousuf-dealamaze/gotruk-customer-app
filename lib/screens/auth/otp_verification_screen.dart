import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/widgets/app_button.dart';

class _OtpStepData {
  const _OtpStepData({required this.type, required this.target});

  final String type;
  final String target;

  String get label => type == 'phone' ? 'Phone' : 'Email';
}

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.type,
    required this.phoneNumber,
    required this.email,
    required this.countryCode,
  });

  final String type;
  final String phoneNumber;
  final String email;
  final String countryCode;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  late final List<_OtpStepData> _steps;
  int _currentStep = 0;

  _OtpStepData get _activeStep => _steps[_currentStep];
  bool get _isLastStep => _currentStep == _steps.length - 1;
  bool get _isPhoneType => _activeStep.type == 'phone';
  String get _label => _activeStep.label;
  String get _targetValue => _activeStep.target;

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() => _secondsLeft = 60);
    } else {
      _secondsLeft = 60;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() => _secondsLeft--);
      }
    });
  }

  List<_OtpStepData> _buildSteps() {
    final phone = widget.phoneNumber.trim();
    final email = widget.email.trim();
    final steps = <_OtpStepData>[];

    if (phone.isNotEmpty) {
      steps.add(_OtpStepData(type: 'phone', target: phone));
    }
    if (email.isNotEmpty) {
      steps.add(_OtpStepData(type: 'email', target: email));
    }

    if (steps.isNotEmpty) {
      return steps;
    }

    final fallbackType = widget.type == 'email' ? 'email' : 'phone';
    final fallbackTarget = fallbackType == 'email' ? email : phone;
    return [_OtpStepData(type: fallbackType, target: fallbackTarget)];
  }

  Future<void> _resendOtp() async {
    final ok = await ref
        .read(authProvider.notifier)
        .sendOtp(
          otpType: _activeStep.type,
          email: _activeStep.type == 'email' ? widget.email : null,
          phoneNumber: _activeStep.type == 'phone' ? widget.phoneNumber : null,
          countryCode: _activeStep.type == 'phone' ? widget.countryCode : null,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'OTP resent successfully' : 'Failed to resend OTP')),
    );
    if (ok) {
      _startTimer();
    }
  }

  Future<void> _verifyOtp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final ok = await ref
        .read(authProvider.notifier)
        .verifyOTP(
          otpType: _activeStep.type,
          otp: _otpController.text.trim(),
          email: _activeStep.type == 'email' ? widget.email : null,
          phoneNumber: _activeStep.type == 'phone' ? widget.phoneNumber : null,
          countryCode: _activeStep.type == 'phone' ? widget.countryCode : null,
        );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP. Please try again.')));
      return;
    }

    if (!_isLastStep) {
      final verifiedLabel = _label;
      final nextLabel = _steps[_currentStep + 1].label;
      _otpController.clear();
      setState(() {
        _currentStep++;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$verifiedLabel verified. Please verify your $nextLabel now.',
          ),
        ),
      );
      return;
    }

    context.go('/login');
  }

  Widget _buildStepIndicator() {
    if (_steps.length < 2) {
      return const SizedBox.shrink();
    }

    return Row(
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineActive = index ~/ 2 < _currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: lineActive ? primaryColor : shadowColor,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isActive = stepIndex == _currentStep;
        final isCompleted = stepIndex < _currentStep;
        final bgColor = (isActive || isCompleted) ? primaryColor : cardColor;
        final textColor = (isActive || isCompleted) ? cardColor : greyFont;

        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: (isActive || isCompleted) ? primaryColor : shadowColor,
            ),
          ),
          child: Text(
            '${stepIndex + 1}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(backgroundColor: backgroundColor, elevation: 0),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepIndicator(),
                      if (_steps.length > 1) const SizedBox(height: 10),
                      if (_steps.length > 1)
                        Text(
                          'Step ${_currentStep + 1} of ${_steps.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: greyFont),
                        ),
                      if (_steps.length > 1) const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Icon(
                            _isPhoneType ? Icons.phone_iphone : Icons.email_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Verify Your $_label',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fontBlack,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We've sent a 6-digit code to $_targetValue",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: greyFont, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Enter OTP',
                        style: TextStyle(
                          color: fontBlack,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fontBlack,
                          fontSize: 22,
                          letterSpacing: 5,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Enter 6-digit OTP',
                          hintStyle: TextStyle(color: greyFont),
                          filled: true,
                          fillColor: cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
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
                        ),
                        validator: (value) {
                          final otp = value?.trim() ?? '';
                          if (otp.isEmpty) return 'OTP is required';
                          if (otp.length != 6) return 'Enter a valid 6-digit OTP';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: _secondsLeft > 0
                            ? Text(
                                'Resend OTP in ${_secondsLeft}s',
                                style: TextStyle(color: greyFont),
                              )
                            : TextButton(
                                onPressed: _resendOtp,
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        text: _isLastStep ? 'Verify OTP' : 'Verify & Next',
                        isLoading: authState.isLoadingPhone,
                        onPressed: _verifyOtp,
                      ),
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
