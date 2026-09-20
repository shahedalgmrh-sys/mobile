import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              accountName: Text('أحمد محمد', style: TextStyle(fontWeight: FontWeight.w700)),
              accountEmail: Text('+967 777 123 456'),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Text('أ')),
            ),
            const SizedBox(height: 16),
            _tile(Icons.wallet_outlined, 'المحفظة', () => context.push('/wallet')),
            _tile(Icons.notifications_outlined, 'الإشعارات', () => context.push('/notifications')),
            _tile(Icons.location_on_outlined, 'العناوين', () => context.push('/addresses')),
            _tile(Icons.favorite_outline, 'المفضلة', () => context.push('/favorites')),
            _tile(Icons.settings_outlined, 'الإعدادات', () => context.push('/settings')),
            _tile(Icons.support_agent_outlined, 'الدعم الفني', () => context.push('/support')),
            const SizedBox(height: 40),
            const EmptyState(
              title: 'نسخة تجريبية',
              subtitle: 'يمكنك إضافة المزيد من التفاصيل هنا لاحقاً',
              icon: Icons.info_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData i, String t, VoidCallback onTap) {
    return ListTile(
      leading: Icon(i, color: const Color(0xFF0F766E)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
