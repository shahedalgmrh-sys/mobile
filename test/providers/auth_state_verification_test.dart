import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/providers/auth_provider.dart';

void main() {
  group('AuthState.needsProviderVerification', () {
    test('customers never require provider verification', () {
      const state = AuthState(
        role: UserRole.customer,
        user: {'role': 'customer'},
      );
      expect(state.needsProviderVerification, isFalse);
    });

    test('verified provider is routed as approved', () {
      const state = AuthState(
        role: UserRole.provider,
        user: {
          'role': 'provider',
          'provider_profile': {'is_verified': true},
        },
      );
      expect(state.needsProviderVerification, isFalse);
    });

    test('verification_status approved is accepted as verified', () {
      const state = AuthState(
        role: UserRole.provider,
        user: {
          'role': 'provider',
          'provider_profile': {'verification_status': 'approved'},
        },
      );
      expect(state.needsProviderVerification, isFalse);
    });

    test('pending provider still needs verification', () {
      const state = AuthState(
        role: UserRole.provider,
        user: {
          'role': 'provider',
          'provider_profile': {'is_verified': false},
        },
      );
      expect(state.needsProviderVerification, isTrue);
    });

    test('rejected provider still needs verification', () {
      const state = AuthState(
        role: UserRole.provider,
        user: {
          'role': 'provider',
          'provider_profile': {
            'is_verified': false,
            'verification_status': 'rejected',
          },
        },
      );
      expect(state.needsProviderVerification, isTrue);
    });

    test('missing provider profile is treated as unverified', () {
      const state = AuthState(
        role: UserRole.provider,
        user: {'role': 'provider'},
      );
      expect(state.needsProviderVerification, isTrue);
    });
  });
}
