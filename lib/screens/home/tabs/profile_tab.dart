import 'package:flutter/material.dart';
import 'package:gotruck_customer/core/theme/colors.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  final String name;
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Profile',
            style: TextStyle(
              color: fontBlack,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: greyFont, size: 42),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              color: fontBlack,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(color: greyFont, fontSize: 12)),
          const SizedBox(height: 20),
          _ProfileItem(
            icon: Icons.person_outline,
            title: 'My profile',
            onTap: () {},
          ),
          _ProfileItem(icon: Icons.favorite_border, title: 'Favorites', onTap: () {}),
          _ProfileItem(icon: Icons.privacy_tip_outlined, title: 'Privacy policy', onTap: () {}),
          _ProfileItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
          _ProfileItem(
            icon: Icons.logout,
            title: 'Log out',
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: shadowColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: greyFont),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: fontBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: greyFont),
            ],
          ),
        ),
      ),
    );
  }
}
