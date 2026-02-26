import 'package:flutter/material.dart';
import 'package:gotruck_customer/router/app_router.dart';
import 'package:gotruck_customer/widgets/app_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Payment method'),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.grey.withValues(alpha: 0.12),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Truck booking success',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You have successfully booked your truck. Please wait for your scheduled date.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        text: 'Go to home',
                        onPressed: () {
                          AppRouter.go('/home/home');
                        },
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
