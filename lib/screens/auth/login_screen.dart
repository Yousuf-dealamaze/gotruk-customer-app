import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/widgets/app_button.dart';
import 'package:gotruck_customer/widgets/app_phone_number_field.dart';
import 'package:gotruck_customer/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+91');
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  late final TabController _tabController;
  bool _isOtpSent = false;

  bool get _isEmailTab => _tabController.index == 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      setState(() {
        _isOtpSent = false;
        _otpController.clear();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Widget _buildOtpPinField() {
    final otp = _otpController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _otpFocusNode.requestFocus(),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final hasValue = index < otp.length;
                  final isActive = index == otp.length && otp.length < 6;
                  return Container(
                    width: 44,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? primaryColor : shadowColor,
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      hasValue ? otp[index] : '',
                      style: TextStyle(
                        color: fontBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextFormField(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 6,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isOtpSent && otp.isNotEmpty && otp.length != 6) ...[
          const SizedBox(height: 6),
          Text(
            'Enter valid 6-digit OTP',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Future<void> _submitPasswordLogin() async {
    final isValid = _emailFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());

    if (!mounted) {
      return;
    }
    if (ok) {
      context.go('/home');
    }
  }

  String _normalizedPhoneNumber() {
    final raw = _phoneController.text.trim();
    final code = _countryCodeController.text.trim();
    if (raw.isEmpty || code.isEmpty) {
      return raw;
    }
    if (raw.startsWith(code)) {
      return raw.substring(code.length).trim();
    }
    return raw;
  }

  Future<void> _sendLoginOtp() async {
    final isValid = _phoneFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    final ok = await ref
        .read(authProvider.notifier)
        .loginWithOtp(
          phoneNumber: _normalizedPhoneNumber(),
          countryCode: _countryCodeController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    if (ok) {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent successfully.')));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to send OTP.')));
  }

  Future<void> _verifyLoginOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP.')),
      );
      return;
    }
    final ok = await ref
        .read(authProvider.notifier)
        .verifyLoginOtp(
          phoneNumber: _normalizedPhoneNumber(),
          countryCode: _countryCodeController.text.trim(),
          otp: otp,
        );
    if (!mounted) {
      return;
    }
    if (ok) {
      context.go('/home');
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP verification failed.')));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const FlutterLogo(size: 110),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back',
                      style: textTheme.headlineSmall?.copyWith(
                        color: fontBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue.',
                      style: textTheme.bodyMedium?.copyWith(color: greyFont),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: cardColor,
                        unselectedLabelColor: greyFont,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tabs: const [
                          Tab(text: 'Email'),
                          Tab(text: 'Phone OTP'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_isEmailTab)
                      Form(
                        key: _emailFormKey,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Minimum 6 characters required';
                                }
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.go('/forgot-password'),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                            ),
                            AppButton(
                              text: 'Login',
                              isLoading: authState.isLoading,
                              onPressed: _submitPasswordLogin,
                            ),
                          ],
                        ),
                      )
                    else
                      Form(
                        key: _phoneFormKey,
                        child: Column(
                          children: [
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
                            if (_isOtpSent) ...[
                              const SizedBox(height: 14),
                              _buildOtpPinField(),
                            ],
                            const SizedBox(height: 16),
                            AppButton(
                              text: _isOtpSent ? 'Verify OTP' : 'Send OTP',
                              isLoading: authState.isLoadingPhone,
                              onPressed: _isOtpSent
                                  ? _verifyLoginOtp
                                  : _sendLoginOtp,
                            ),
                            if (_isOtpSent)
                              TextButton(
                                onPressed: _sendLoginOtp,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: greyFont),
                        ),
                        TextButton(
                          onPressed: () => context.go('/signup'),
                          child: Text(
                            'Signup',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
