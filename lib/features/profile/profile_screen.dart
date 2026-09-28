import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/favorites_store.dart';
import '../premium/premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceElevated,
                child: Icon(Icons.person, color: AppColors.textSecondary, size: 32),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Гитарист',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('Новичок', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatTile(label: 'Избранное', value: '${favorites.count}'),
              const SizedBox(width: 12),
              const _StatTile(label: 'Подборки', value: '${6}'),
              const SizedBox(width: 12),
              const _StatTile(label: 'Аккорды', value: '20'),
            ],
          ),
          const SizedBox(height: 24),
          _MenuTile(
            icon: Icons.favorite_border,
            label: 'Избранное',
            trailingText: '${favorites.count}',
            onTap: () {},
          ),
          const _MenuTile(icon: Icons.history_rounded, label: 'История просмотров'),
          const _MenuTile(icon: Icons.settings_outlined, label: 'Настройки'),
          const _MenuTile(icon: Icons.help_outline_rounded, label: 'Помощь и поддержка'),
          const SizedBox(height: 16),
          _PremiumBanner(onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
          }),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.trailingText, this.onTap});
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: trailingText != null
          ? Text(trailingText!, style: const TextStyle(color: AppColors.textSecondary))
          : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.heroGradient),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: Colors.black),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Больше возможностей — открой всё приложение',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
