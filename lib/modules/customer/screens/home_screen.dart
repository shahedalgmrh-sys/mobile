import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import '../../../models/service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demo = Service(
      id: '1',
      slug: 'cleaning',
      titleAr: 'تنظيف المنازل',
      titleEn: 'Home Cleaning',
      basePrice: 1500,
      currencyCode: 'yer',
      ratingAvg: 4.8,
      reviewsCount: 124,
      categoryId: 'cat1',
      imageUrl: null,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية'), actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () => context.push('/favorites'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
        ),
      ]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ServiceCard(
              service: demo,
              onTap: () => context.push('/services/cleaning'),
              onBookNow: () => context.push('/bookings/new'),
            ),
            const SizedBox(height: 16),
            ServiceCard(
              service: Service(
                id: '2',
                slug: 'plumbing',
                titleAr: 'خدمات السباكة',
                titleEn: 'Plumbing',
                basePrice: 2000,
                currencyCode: 'yer',
                ratingAvg: 4.6,
                reviewsCount: 89,
                categoryId: 'cat2',
                discountPercent: 15,
              ),
              onTap: () => context.push('/services/plumbing'),
              onBookNow: () => context.push('/bookings/new'),
            ),
          ],
        ),
      ),
    );
  }
}
