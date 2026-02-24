import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key, this.hasNotifications = true});

  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    if (!hasNotifications) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Notifications',
              style: TextStyle(
                color: fontBlack,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none, color: primaryColor, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: fontBlack,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your notifications list is empty please\nwait for some updates and go to home',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyFont),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Go to home'),
              ),
            ),
            const Spacer(),
          ],
        ),
      );
    }

    const notifications = [
      (
        title: 'Truck booking is confirmed',
        subtitle: 'Your truck booking for 05-03 from\nnew jersey is confirmed.',
        time: '30 seconds ago',
      ),
      (
        title: 'Your shipment is on the move',
        subtitle: 'Your upcoming truck booking is\nscheduled for 04-03 at 10:30AM.',
        time: '1 day ago',
      ),
      (
        title: 'New feature alert',
        subtitle: 'Track your truck location in real-time\nwith our app',
        time: '2 days ago',
      ),
      (
        title: 'Booking confirmation received',
        subtitle: 'Your truck is booked and ready to\nhandle your cargo.',
        time: '1 week ago',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Notifications',
            style: TextStyle(
              color: fontBlack,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: shadowColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEF9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.notifications, color: primaryColor, size: 12),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: fontBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              style: TextStyle(color: greyFont, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.time,
                              style: TextStyle(color: greyFont, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
