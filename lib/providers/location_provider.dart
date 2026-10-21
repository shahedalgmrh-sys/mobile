import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.source,
    this.city,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String source;
  final String? city;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
        'city': city,
      };

  factory AppLocation.fromJson(Map<String, dynamic> json) => AppLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        source: json['source']?.toString() ?? 'cached',
        city: json['city']?.toString(),
      );
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppLocationNotifier extends AsyncNotifier<AppLocation?> {
  static const _storageKey = 'app_last_location';

  @override
  Future<AppLocation?> build() => _loadSaved();

  Future<AppLocation?> useCurrentLocation({bool forceRefresh = false}) async {
    final cached = state.valueOrNull ?? await _loadSaved();
    if (!forceRefresh && cached != null && _isFresh(cached)) {
      state = AsyncData(cached);
      return cached;
    }

    state = const AsyncLoading();

    try {
      final location = await _resolveLocation(cached: cached);
      await _persist(location);
      state = AsyncData(location);
      return location;
    } catch (error, stackTrace) {
      if (cached != null) {
        state = AsyncData(cached);
        return cached;
      }
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AppLocation?> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return AppLocation.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(AppLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(location.toJson()));
  }

  Future<AppLocation> _resolveLocation({AppLocation? cached}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'خدمة الموقع متوقفة. فعّلي GPS أو الموقع عبر الشبكة ثم أعيدي المحاولة.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('تم رفض إذن الوصول إلى الموقع.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'إذن الموقع مرفوض نهائيًا. فعّليه من إعدادات الجهاز.',
      );
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    final candidates = <AppLocation>[
      if (lastKnown != null)
        await _toLocation(lastKnown, source: 'آخر موقع معروف'),
      if (cached != null) cached,
    ];

    try {
      final gps = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 8),
      );
      candidates.add(await _toLocation(gps, source: 'GPS عالي الدقة'));
    } catch (_) {}

    try {
      final networkAssisted = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      candidates.add(
        await _toLocation(
          networkAssisted,
          source: 'شبكة/Wi-Fi مساعدة',
        ),
      );
    } catch (_) {}

    if (candidates.isEmpty) {
      throw const LocationException(
        'تعذر الحصول على موقعك الحالي. جرّبي مكانًا مفتوحًا أو أعيدي المحاولة بعد لحظات.',
      );
    }

    candidates.sort(_compareLocations);
    return candidates.first;
  }

  Future<AppLocation> _toLocation(
    Position position, {
    required String source,
  }) async {
    String? city;
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = places.isEmpty ? null : places.first;
      city = place?.locality?.trim().isNotEmpty == true
          ? place!.locality!.trim()
          : place?.subAdministrativeArea?.trim().isNotEmpty == true
              ? place!.subAdministrativeArea!.trim()
              : place?.administrativeArea?.trim();
    } catch (_) {
      city = null;
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      source: source,
      city: city,
    );
  }

  int _compareLocations(AppLocation a, AppLocation b) {
    final accuracy = a.accuracy.compareTo(b.accuracy);
    if (accuracy != 0) return accuracy;
    return b.timestamp.compareTo(a.timestamp);
  }

  bool _isFresh(AppLocation location) =>
      DateTime.now().difference(location.timestamp) < const Duration(minutes: 10);
}

final appLocationProvider =
    AsyncNotifierProvider<AppLocationNotifier, AppLocation?>(
  AppLocationNotifier.new,
);
