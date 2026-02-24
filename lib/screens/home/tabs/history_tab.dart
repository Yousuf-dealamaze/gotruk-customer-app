import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: shadowColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, size: 40, color: primaryColor),
            const SizedBox(height: 10),
            Text(
              'No trip history yet',
              style: TextStyle(
                color: fontBlack,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Completed bookings will appear here.',
              style: TextStyle(color: greyFont),
            ),
          ],
        ),
      ),
    );
  }
}
