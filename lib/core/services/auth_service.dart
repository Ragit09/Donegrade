import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loginKey = 'isLoggedIn';
  
  // Global notifier to listen to auth or profile changes
  static final ValueNotifier<bool> authStateNotifier = ValueNotifier(false);

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_loginKey) ?? false;
    // Sinkronkan state awal (tanpa memicu listener berlebihan)
    if (authStateNotifier.value != loggedIn) {
      authStateNotifier.value = loggedIn;
    }
    return loggedIn;
  }

  static Future<void> registerUser(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan kredensial seolah-olah ini database
    await prefs.setString('reg_name_$email', name);
    await prefs.setString('reg_password_$email', password);
  }

  static Future<String?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cari user di "database"
    final savedPassword = prefs.getString('reg_password_$email');
    
    if (savedPassword == null) {
      return 'Akun tidak ditemukan. Silakan buat akun.';
    }
    
    if (savedPassword != password) {
      return 'Kata sandi salah!';
    }
    
    // Sukses
    final name = prefs.getString('reg_name_$email') ?? 'Pengguna';
    await prefs.setBool(_loginKey, true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    
    // Trigger update
    authStateNotifier.value = !authStateNotifier.value;
    authStateNotifier.value = true;
    
    return null; // Tidak ada error
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    
    // Trigger update
    authStateNotifier.value = false;
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? '';
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Pengguna';
  }

  static Future<void> updateProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    // Update data registrasi lokal (simulasi database) agar tetap tersimpan
    await prefs.setString('reg_name_$email', name);
    
    // Trigger update by toggling the notifier temporarily to force listeners to rebuild
    final current = authStateNotifier.value;
    authStateNotifier.value = !current;
    authStateNotifier.value = current;
  }

  static Future<String?> changePassword(String email, String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('reg_password_$email');
    
    if (savedPassword == null) {
      return 'Akun tidak ditemukan.';
    }
    
    if (savedPassword != oldPassword) {
      return 'Kata sandi lama salah!';
    }
    
    await prefs.setString('reg_password_$email', newPassword);
    return null; // Sukses
  }

  static Future<String?> resetPassword(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('reg_password_$email');
    
    if (savedPassword == null) {
      return 'Email tidak terdaftar dalam sistem.';
    }
    
    // Simulasi pengiriman email
    await Future.delayed(const Duration(seconds: 1));
    return null; // Sukses
  }
}
