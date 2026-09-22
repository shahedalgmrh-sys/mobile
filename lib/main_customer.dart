import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers.dart';
import 'models/app_config.dart';
import 'app/sahel_app.dart';

void main() {
  final config = AppConfig.customer();
  runApp(ProviderScope(
    overrides: [appConfigProvider.overrideWithValue(config)],
    child: SahelApp(config: config),
  ));
}
