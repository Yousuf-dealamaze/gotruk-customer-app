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
      SnackBar(
        content: Text(ok ? 'OTP resent successfully' : 'Failed to resend OTP'),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
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
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FAFB), Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// Step Indicator
                        _buildStepIndicator(),

                        if (_steps.length > 1) const SizedBox(height: 12),

                        if (_steps.length > 1)
                          Text(
                            'Step ${_currentStep + 1} of ${_steps.length}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: greyFont, fontSize: 14),
                          ),

                        const SizedBox(height: 20),

                        /// Icon
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.gradientPrimary,
                            ),
                            child: Icon(
                              _isPhoneType
                                  ? Icons.phone_iphone
                                  : Icons.email_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Title
                        Text(
                          'Verify Your $_label',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: fontBlack,
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// Subtitle
                        Text(
                          "We've sent a 6-digit code to",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: greyFont, fontSize: 15),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _targetValue,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// OTP Label
                        Text(
                          'Enter OTP',
                          style: TextStyle(
                            color: fontBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// OTP Field
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: fontBlack,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 6,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '••••••',
                            hintStyle: TextStyle(
                              color: greyFont.withOpacity(0.5),
                              letterSpacing: 6,
                            ),
                            filled: true,
                            fillColor: backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final otp = value?.trim() ?? '';
                            if (otp.isEmpty) return 'OTP is required';
                            if (otp.length != 6) {
                              return 'Enter a valid 6-digit OTP';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// Timer / Resend
                        Center(
                          child: _secondsLeft > 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Resend in ${_secondsLeft}s',
                                      style: TextStyle(color: greyFont),
                                    ),
                                  ],
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

                        const SizedBox(height: 20),

                        /// Button
                        AppButton(
                          text: _isLastStep ? 'Verify OTP' : 'Verify & Next',
                          isLoading: authState.isLoadingPhone,
                          onPressed: _verifyOtp,
                        ),

                        const SizedBox(height: 12),

                        /// Footer
                        Text(
                          'Didn’t receive the code? Check spam or try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: greyFont, fontSize: 12),
                        ),
                      ],
                    ),
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
