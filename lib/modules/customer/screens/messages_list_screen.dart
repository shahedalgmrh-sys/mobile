import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const CircleAvatar(child: Text('م')),
              title: const Text('محمد الفني - تنظيف', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('شكراً لك، سأكون في الموعد المحدد'),
              trailing: const Text('2:30 م', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              onTap: () => context.push('/inbox/thread_123'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(child: Text('أ')),
              title: const Text('أحمد السباك', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('أحتاج صورة للمشكلة من فضلك'),
              trailing: const Text('أمس', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              onTap: () => context.push('/inbox/thread_456'),
            ),
            const Divider(height: 1),
            const SizedBox(height: 40),
            const EmptyState(
              title: 'لا توجد رسائل أخرى',
              subtitle: 'تبدأ المحادثة مع مزود الخدمة بعد الحجز',
              icon: Icons.chat_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
