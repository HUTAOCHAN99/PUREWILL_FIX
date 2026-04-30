import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/repository/secure_storage_repository.dart';
import 'package:purewill/data/services/auth/auth_service.dart';
import 'package:purewill/data/services/auth/biometric_service.dart';
import 'package:purewill/domain/model/auth_model.dart';

class FakeSecureStorageRepository extends SecureStorageRepository {
  String? storedAccessToken;
  String? storedRefreshTokenCookie;
  bool biometricEnabled = false;
  bool clearSessionTokensCalled = false;

  @override
  Future<String?> getAccessToken() async => storedAccessToken;

  @override
  Future<String?> getRefreshTokenCookie() async => storedRefreshTokenCookie;

  @override
  Future<void> saveAccessToken(String token) async {
    storedAccessToken = token;
  }

  @override
  Future<void> saveRefreshTokenCookie(String cookie) async {
    storedRefreshTokenCookie = cookie;
  }

  @override
  Future<void> clearAccessToken() async {
    storedAccessToken = null;
  }

  @override
  Future<bool> isBiometricEnabled() async => biometricEnabled;

  @override
  Future<void> clearSessionTokens() async {
    clearSessionTokensCalled = true;
    storedAccessToken = null;
    storedRefreshTokenCookie = null;
  }
}

class FakeBiometricService extends BiometricService {
  FakeBiometricService({required this.nextResult});

  BiometricResult nextResult;
  int authenticateCallCount = 0;

  @override
  Future<BiometricResult> authenticate({
    required String reason,
    String? title,
    String? subtitle,
    String? cancelButtonText,
  }) async {
    authenticateCallCount++;
    return nextResult;
  }
}

class FakeAuthService extends AuthService {
  FakeAuthService({this.onCheckSession, this.onRefreshSession});

  final Future<Map<String, dynamic>> Function({required bool skipRefresh})?
  onCheckSession;
  final Future<Map<String, dynamic>> Function()? onRefreshSession;

  String? _token;
  String? _cookie;

  int checkSessionCallCount = 0;
  int refreshSessionCallCount = 0;

  @override
  String? get accessToken => _token;

  @override
  String? get refreshTokenCookie => _cookie;

  @override
  void setAccessToken(String token) {
    _token = token;
  }

  @override
  void setRefreshTokenCookie(String cookie) {
    _cookie = cookie;
  }

  @override
  Future<Map<String, dynamic>> checkSession({bool skipRefresh = false}) async {
    checkSessionCallCount++;
    if (onCheckSession != null) {
      return onCheckSession!(skipRefresh: skipRefresh);
    }
    throw AuthException('checkSession not configured');
  }

  @override
  Future<Map<String, dynamic>> refreshSession() async {
    refreshSessionCallCount++;
    if (onRefreshSession != null) {
      return onRefreshSession!();
    }
    throw AuthException('refreshSession not configured');
  }
}

Map<String, dynamic> _sessionResponse() {
  return {
    'data': {
      'id': 'user-1',
      'email': 'user@example.com',
      'username': 'user',
      'profile': {'fullname': 'Test User'},
    },
  };
}

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_HOST=localhost\nAPI_PORT=4000');
  });

  group('AuthRepository.restoreSession', () {
    test('returns user immediately when access token is valid', () async {
      final fakeStorage = FakeSecureStorageRepository()
        ..storedAccessToken = 'valid-token'
        ..storedRefreshTokenCookie = 'refreshToken=abc'
        ..biometricEnabled = true;

      final fakeBiometric = FakeBiometricService(
        nextResult: BiometricResult(success: true),
      );

      final fakeAuth = FakeAuthService(
        onCheckSession: ({required skipRefresh}) async {
          expect(skipRefresh, isTrue);
          return _sessionResponse();
        },
      );

      final repository = AuthRepository(fakeAuth, fakeStorage, fakeBiometric);

      final user = await repository.restoreSession(requireBiometric: true);

      expect(user, isNotNull);
      expect(user!.email, 'user@example.com');
      expect(fakeAuth.refreshSessionCallCount, 0);
      expect(fakeBiometric.authenticateCallCount, 0);
      expect(fakeStorage.clearSessionTokensCalled, isFalse);
    });

    test(
      'refreshes session only after biometric success when token expired',
      () async {
        final fakeStorage = FakeSecureStorageRepository()
          ..storedAccessToken = 'expired-token'
          ..storedRefreshTokenCookie = 'refreshToken=abc'
          ..biometricEnabled = true;

        final fakeBiometric = FakeBiometricService(
          nextResult: BiometricResult(success: true),
        );

        var checkCalls = 0;
        late final FakeAuthService fakeAuth;
        fakeAuth = FakeAuthService(
          onCheckSession: ({required skipRefresh}) async {
            checkCalls++;
            if (checkCalls == 1) {
              expect(skipRefresh, isTrue);
              throw AuthException('Unauthorized');
            }
            expect(skipRefresh, isFalse);
            return _sessionResponse();
          },
          onRefreshSession: () async {
            fakeAuth.setAccessToken('new-access-token');
            fakeAuth.setRefreshTokenCookie('refreshToken=new-cookie');
            return {'accessToken': 'new-access-token'};
          },
        );

        final repository = AuthRepository(fakeAuth, fakeStorage, fakeBiometric);

        final user = await repository.restoreSession(requireBiometric: true);

        expect(user, isNotNull);
        expect(fakeBiometric.authenticateCallCount, 1);
        expect(fakeAuth.refreshSessionCallCount, 1);
        expect(fakeStorage.storedAccessToken, 'new-access-token');
        expect(fakeStorage.storedRefreshTokenCookie, 'refreshToken=new-cookie');
        expect(fakeStorage.clearSessionTokensCalled, isFalse);
      },
    );

    test('clears session and does not refresh when biometric fails', () async {
      final fakeStorage = FakeSecureStorageRepository()
        ..storedAccessToken = 'expired-token'
        ..storedRefreshTokenCookie = 'refreshToken=abc'
        ..biometricEnabled = true;

      final fakeBiometric = FakeBiometricService(
        nextResult: BiometricResult(success: false, errorMessage: 'Canceled'),
      );

      final fakeAuth = FakeAuthService(
        onCheckSession: ({required skipRefresh}) async {
          throw AuthException('Unauthorized');
        },
      );

      final repository = AuthRepository(fakeAuth, fakeStorage, fakeBiometric);

      final user = await repository.restoreSession(requireBiometric: true);

      expect(user, isNull);
      expect(fakeBiometric.authenticateCallCount, 1);
      expect(fakeAuth.refreshSessionCallCount, 0);
      expect(fakeStorage.clearSessionTokensCalled, isTrue);
      expect(fakeStorage.storedAccessToken, isNull);
      expect(fakeStorage.storedRefreshTokenCookie, isNull);
    });
  });
}
