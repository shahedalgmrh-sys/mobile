import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import '../../../models/booking_status.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/bookings/new'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: () => context.push('/bookings/1'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('تنظيف منزل كامل',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        BookingStatusPill(status: BookingStatus.inProgress),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('20 سبتمبر 2026 · 10:00 صباحاً',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => context.push('/bookings/1/track'),
                          child: const Text('تتبع الحجز'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/bookings/1/review'),
                          child: const Text('تقييم'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/bookings/2'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('صيانة تكييف',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        BookingStatusPill(status: BookingStatus.pending),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('25 سبتمبر 2026 · 2:00 عصراً',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const EmptyState(
              title: 'لا توجد حجوزات أخرى',
              subtitle: 'ابدأ بحجز أول خدمة منزلية',
              icon: Icons.calendar_month_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
