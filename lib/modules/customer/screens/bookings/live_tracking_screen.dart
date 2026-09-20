import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: SahelColors.primary50,
            child: SizedBox.expand(
              child: Placeholder(
                color: SahelColors.primary200,
                fallbackWidth: 300,
                fallbackHeight: 300,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'خريطة متابعة الفني - GPS Polyline + ETA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: SahelColors.primary700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: SahelColors.shadowSm, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: const Icon(Icons.arrow_back, color: SahelColors.text),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 24,
              shadowColor: SahelColors.text.withOpacity(0.2),
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car, color: SahelColors.primary700, size: 24),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'الفني في الطريق…',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Chip(
                          label: const Text(
                            'يصل خلال: 7 دقائق',
                            style: TextStyle(color: SahelColors.amber700, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          backgroundColor: SahelColors.amberSoft,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const ProviderMiniCard(),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SahelButton.soft(
                            icon: Icons.call,
                            label: 'اتصال سريع',
                            onPressed: () async {
                              final tel = Uri.parse('tel:+967777123456');
                              if (await canLaunchUrl(tel)) await launchUrl(tel);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SahelButton.soft(
                            icon: Icons.chat,
                            label: 'مراسلة',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 48,
                          child: SahelButton.gradient(
                            icon: Icons.navigation,
                            label: '',
                            onPressed: () async {
                              final maps = Uri.parse('https://maps.google.com/?q=15.3694,44.1910');
                              if (await canLaunchUrl(maps)) await launchUrl(maps);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
