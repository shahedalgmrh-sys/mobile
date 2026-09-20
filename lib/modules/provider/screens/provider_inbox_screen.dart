import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderInboxScreen extends StatelessWidget {
  const ProviderInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const CircleAvatar(child: Text('أ')),
              title: const Text('أحمد محمد', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('شكراً على الخدمة الممتازة!'),
              trailing: const Text('12:04', style: TextStyle(fontSize: 11, color: SahelColors.muted)),
              onTap: () => context.push('/p/inbox/t1'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(child: Text('س')),
              title: const Text('سارة علي', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('متى يمكنك المجيء؟'),
              trailing: const Text('أمس', style: TextStyle(fontSize: 11, color: SahelColors.muted)),
              onTap: () => context.push('/p/inbox/t2'),
            ),
          ],
        ),
      ),
    );
  }
}
