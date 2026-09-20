import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class LiveTrackingScreen extends StatelessWidget {
  final String id;

  const LiveTrackingScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع مباشر')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: SahelColors.primary50,
              child: const Center(
                child: Icon(Icons.map_outlined, size: 80, color: SahelColors.primary200),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Text('م')),
                    title: const Text('محمد الفني',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Row(
                      children: const [
                        Icon(Icons.star, size: 14, color: SahelColors.amber500),
                        SizedBox(width: 2),
                        Text('4.9 · وصل خلال 15 دقيقة',
                            style: TextStyle(fontSize: 12, color: SahelColors.muted)),
                      ],
                    ),
                    trailing: const Icon(Icons.phone_in_talk, color: SahelColors.primary600),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.6,
                    color: SahelColors.primary500,
                    backgroundColor: SahelColors.slate200,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SahelButton.soft(label: 'محادثة', onTap: () {}),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SahelButton(
                            label: 'إلغاء الحجز',
                            variant: SahelButtonVariant.danger,
                            onPressed: () {}),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
