import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/app_config.dart';
import 'app/sahel_app.dart';

void main() {
  final config = AppConfig.provider();
  runApp(ProviderScope(child: SahelApp(config: config)));
}
