import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const String _userKey = 'user_data';
  bool _isAuthenticated = false;
  String? _userEmail;
  SharedPreferences? _prefs;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;

  Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      // Check if user is already logged in
      final userData = _prefs!.getString(_userKey);
      if (userData != null) {
        final data = json.decode(userData);
        _isAuthenticated = true;
        _userEmail = data['email'];
        notifyListeners();
      }
    }
  }

  Future<bool> register(String email, String password) async {
    await _initPrefs();
    try {
      // Check if user already exists
      final usersJson = _prefs!.getString('users') ?? '{}';
      final users = json.decode(usersJson) as Map<String, dynamic>;
      
      if (users.containsKey(email)) {
        return false; // User already exists
      }

      // Store new user
      users[email] = {
        'email': email,
        'password': password,
      };
      await _prefs!.setString('users', json.encode(users));
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    await _initPrefs();
    try {
      final usersJson = _prefs!.getString('users') ?? '{}';
      final users = json.decode(usersJson) as Map<String, dynamic>;
      
      final user = users[email];
      if (user != null && user['password'] == password) {
        _isAuthenticated = true;
        _userEmail = email;
        
        // Store current user data
        await _prefs!.setString(_userKey, json.encode({
          'email': email,
          'isAuthenticated': true,
        }));
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.remove(_userKey);
    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }
}