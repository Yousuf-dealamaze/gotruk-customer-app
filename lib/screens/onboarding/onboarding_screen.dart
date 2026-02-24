import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/services/local_storage_service.dart';
import 'package:gotruck_customer/widgets/app_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int currentIndex = 0;

  final pages = [
    {
      "title": "Trusted truck booking\nfor peace of mind",
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "Skip the hassle, get\nyour truck on demand",
      "image": "assets/images/onboarding2.png",
    },
    {
      "title": "Reliable truck booking\nat your fingertips",
      "image": "assets/images/onboarding3.png",
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorageService().setHasSeenOnboarding(true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Pages
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return buildPage(pages[index]);
                },
              ),
            ),

            // Indicator
            SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.blue,
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: AppButton(
                text: currentIndex == pages.length - 1 ? "Get Started" : "Next",
                onPressed: () async {
                  if (currentIndex == pages.length - 1) {
                    await _completeOnboarding();
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),

            TextButton(
              onPressed: () async {
                await _completeOnboarding();
              },
              child: const Text("Skip"),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildPage(Map data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circle Image
        ClipOval(
          child: Image.asset(
            data["image"],
            height: 220,
            width: 220,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          data["title"],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        const Text(
          "Say goodbye to logistics headaches\nbooking at your fingertips.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
