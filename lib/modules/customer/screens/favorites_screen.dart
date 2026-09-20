import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import '../../../models/service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Service(
      id: '1',
      slug: 'ac',
      titleAr: 'صيانة المكيفات',
      titleEn: 'AC Maintenance',
      basePrice: 1800,
      currencyCode: 'yer',
      ratingAvg: 4.7,
      reviewsCount: 65,
      categoryId: 'hvac',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ServiceCard(service: s, onTap: () {}, onBookNow: () {}),
            const SizedBox(height: 40),
            const EmptyState(
              title: 'المزيد من الخدمات المفضلة قريباً',
              subtitle: 'اضغط على أيقونة القلب في أي خدمة لإضافتها هنا',
              icon: Icons.favorite_border,
            ),
          ],
        ),
      ),
    );
  }
}
