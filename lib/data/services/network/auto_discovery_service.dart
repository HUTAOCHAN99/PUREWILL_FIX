// lib/data/services/network/auto_discovery_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AutoDiscoveryService {
  static final AutoDiscoveryService _instance = AutoDiscoveryService._internal();
  factory AutoDiscoveryService() => _instance;
  AutoDiscoveryService._internal();
  
  RawDatagramSocket? _socket;
  Timer? _refreshTimer;
  String? _foundBackendUrl;
  final List<void Function(String)> _listeners = [];
  bool _isDiscovering = false;
  
  void addListener(void Function(String url) listener) {
    _listeners.add(listener);
  }
  
  void removeListener(void Function(String url) listener) {
    _listeners.remove(listener);
  }
  
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    _isDiscovering = true;
    
    if (kIsWeb) {
      await _webDiscovery();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _mobileDiscovery();
    } else {
      await _desktopDiscovery();
    }
  }
  
  Future<void> _webDiscovery() async {
    try {
      if (kDebugMode) print('🌐 Web discovery started');
      
      final possibleIps = [
        'localhost',
        '127.0.0.1',
        '192.168.1.1',
        '192.168.1.5',
        '192.168.1.10',
        '192.168.1.100',
        '192.168.0.1',
        '192.168.0.5',
        '192.168.0.100',
        '10.0.2.2',
      ];
      
      for (var ip in possibleIps) {
        final testUrl = 'http://$ip:4000/api/auth/sessions';
        if (await _testConnection(testUrl)) {
          _foundBackendUrl = 'http://$ip:4000/api';
          if (kDebugMode) print('✅ Web discovery found: $_foundBackendUrl');
          _notifyListeners(_foundBackendUrl!);
          _isDiscovering = false;
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      _foundBackendUrl = 'http://localhost:4000/api';
      if (kDebugMode) print('⚠️ Web discovery fallback: $_foundBackendUrl');
      _notifyListeners(_foundBackendUrl!);
      
    } catch (e) {
      if (kDebugMode) print('❌ Web discovery error: $e');
      _foundBackendUrl = 'http://localhost:4000/api';
      _notifyListeners(_foundBackendUrl!);
    }
    
    _isDiscovering = false;
  }
  
  Future<void> _mobileDiscovery() async {
    try {
      if (kDebugMode) print('📱 Mobile discovery started');
      
      final possibleIps = [
        '192.168.1.1',
        '192.168.1.5',
        '192.168.1.10',
        '192.168.1.100',
        '192.168.0.1',
        '192.168.0.5',
        '192.168.0.100',
        '10.0.2.2',
      ];
      
      for (var ip in possibleIps) {
        final testUrl = 'http://$ip:4000/api/auth/sessions';
        if (await _testConnection(testUrl)) {
          _foundBackendUrl = 'http://$ip:4000/api';
          if (kDebugMode) print('✅ Mobile discovery found: $_foundBackendUrl');
          _notifyListeners(_foundBackendUrl!);
          _isDiscovering = false;
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      _foundBackendUrl = 'http://10.0.2.2:4000/api';
      if (kDebugMode) print('⚠️ Mobile discovery fallback: $_foundBackendUrl');
      _notifyListeners(_foundBackendUrl!);
      
    } catch (e) {
      if (kDebugMode) print('❌ Mobile discovery error: $e');
      _foundBackendUrl = 'http://10.0.2.2:4000/api';
      _notifyListeners(_foundBackendUrl!);
    }
    
    _isDiscovering = false;
  }
  
  Future<void> _desktopDiscovery() async {
    try {
      if (kDebugMode) print('💻 Desktop discovery started');
      
      if (await _testConnection('http://localhost:4000/api/auth/sessions')) {
        _foundBackendUrl = 'http://localhost:4000/api';
        if (kDebugMode) print('✅ Desktop discovery found: $_foundBackendUrl');
        _notifyListeners(_foundBackendUrl!);
        _isDiscovering = false;
        return;
      }
      
      final possibleIps = [
        '127.0.0.1',
        '192.168.1.5',
        '192.168.1.100',
        '10.0.2.2',
      ];
      
      for (var ip in possibleIps) {
        final testUrl = 'http://$ip:4000/api/auth/sessions';
        if (await _testConnection(testUrl)) {
          _foundBackendUrl = 'http://$ip:4000/api';
          if (kDebugMode) print('✅ Desktop discovery found: $_foundBackendUrl');
          _notifyListeners(_foundBackendUrl!);
          _isDiscovering = false;
          return;
        }
      }
      
      _foundBackendUrl = 'http://localhost:4000/api';
      if (kDebugMode) print('⚠️ Desktop discovery fallback: $_foundBackendUrl');
      _notifyListeners(_foundBackendUrl!);
      
    } catch (e) {
      if (kDebugMode) print('❌ Desktop discovery error: $e');
      _foundBackendUrl = 'http://localhost:4000/api';
      _notifyListeners(_foundBackendUrl!);
    }
    
    _isDiscovering = false;
  }
  
  Future<bool> _testConnection(String url) async {
    try {
      final client = http.Client();
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 2));
      client.close();
      return response.statusCode != 0;
    } catch (e) {
      return false;
    }
  }
  
  void _notifyListeners(String url) {
    for (var listener in _listeners) {
      listener(url);
    }
  }
  
  void stopDiscovery() {
    _refreshTimer?.cancel();
    _socket?.close();
    _isDiscovering = false;
  }
  
  void setBackendUrl(String url) {
    _foundBackendUrl = url;
    if (kDebugMode) print('🔧 Manual backend URL set: $url');
    _notifyListeners(url);
  }
  
  String? getCurrentUrl() {
    return _foundBackendUrl;
  }
}