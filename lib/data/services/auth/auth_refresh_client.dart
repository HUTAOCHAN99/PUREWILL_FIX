import 'package:http/http.dart' as http;
import 'package:purewill/data/repository/auth_repository.dart';

class AuthRefreshClient extends http.BaseClient {
  AuthRefreshClient(this._inner, this._authRepository, {this.onTokenRefreshed});

  final http.Client _inner;
  final AuthRepository? _authRepository;
  final void Function(String token)? onTokenRefreshed;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);

    if (response.statusCode != 401 || _authRepository == null) {
      return response;
    }

    final refreshedToken = await _authRepository.refreshAccessToken();
    if (refreshedToken == null || refreshedToken.isEmpty) {
      return response;
    }

    onTokenRefreshed?.call(refreshedToken);

    final retryRequest = _cloneRequest(request);
    if (retryRequest == null) {
      return response;
    }

    retryRequest.headers['Authorization'] = 'Bearer $refreshedToken';

    return _inner.send(retryRequest);
  }

  http.BaseRequest? _cloneRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final clone = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection
        ..body = request.body;
      return clone;
    }

    if (request is http.MultipartRequest) {
      final clone = http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
      return clone;
    }

    return null;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
