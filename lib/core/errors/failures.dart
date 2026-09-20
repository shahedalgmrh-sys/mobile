sealed class Failure {
  const Failure();
}

final class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  bool operator ==(Object other) => other is NetworkFailure;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class ServerFailure extends Failure {
  final int code;
  final String message;

  const ServerFailure({
    required this.code,
    required this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerFailure &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(code, message);
}

final class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure({
    required this.errors,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationFailure && _mapsEqual(other.errors, errors);
  }

  static bool _mapsEqual(Map<String, List<String>> a, Map<String, List<String>> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final la = a[key]!;
      final lb = b[key]!;
      if (la.length != lb.length) return false;
      for (int i = 0; i < la.length; i++) {
        if (la[i] != lb[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => errors.hashCode;
}

final class AuthFailure extends Failure {
  const AuthFailure();

  @override
  bool operator ==(Object other) => other is AuthFailure;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();

  @override
  bool operator ==(Object other) => other is UnauthorizedFailure;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class BusinessRuleFailure extends Failure {
  final String code;
  final String message;

  const BusinessRuleFailure({
    required this.code,
    required this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessRuleFailure &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(code, message);
}
