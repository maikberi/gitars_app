import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    'Транспонирование тональности',
    'Автопрокрутка текста',
    'Расширенные подборки',
    'Сохранение коллекций офлайн',
    'Без рекламы',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Премиум')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 56),
              const SizedBox(height: 12),
              const Text(
                'Больше песен. Больше возможностей.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              ..._features.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(f, style: const TextStyle(color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Оплата пока не подключена')),
                  );
                },
                child: const Text('Оформить подписку'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Демонстрационный экран. Реальная оплата не подключена.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
