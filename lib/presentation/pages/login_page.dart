import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/toast_util.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastUtil.showTopToast(context, 'Email dan Password harus diisi!', color: Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
    final errorMsg = await AuthService.loginUser(_emailController.text, _passwordController.text);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMsg != null) {
      ToastUtil.showTopToast(context, errorMsg, color: Colors.redAccent);
    } else {
      ToastUtil.showTopToast(context, 'Login Berhasil!', color: const Color(0xFF10B981));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController(text: _emailController.text);
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Lupa Kata Sandi?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Masukkan alamat email yang terdaftar. Kami akan melakukan verifikasi via Google dan mengirimkan tautan konfirmasi.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailResetController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Alamat Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isResetting ? null : () async {
                    if (emailResetController.text.isEmpty) {
                      ToastUtil.showTopToast(context, 'Email tidak boleh kosong!', color: Colors.redAccent);
                      return;
                    }
                    setDialogState(() => isResetting = true);
                    
                    ToastUtil.showTopToast(context, 'Sedang memverifikasi dengan Google...');
                    
                    final errorMsg = await AuthService.resetPassword(emailResetController.text);
                    
                    if (!mounted) return;
                    
                    if (errorMsg != null) {
                      setDialogState(() => isResetting = false);
                      ToastUtil.showTopToast(context, errorMsg, color: Colors.redAccent);
                    } else {
                      Navigator.pop(context);
                      ToastUtil.showTopToast(context, 'Verifikasi berhasil! Notifikasi konfirmasi telah masuk ke email Anda.', color: const Color(0xFF10B981));
                    }
                  },
                  child: isResetting 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Verifikasi', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B82F6).withOpacity(0.1) : const Color(0xFF1E3A8A).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B82F6).withOpacity(0.2) : const Color(0xFF1E3A8A).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_person_rounded, size: 60, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'Selamat Datang Kembali!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk ke akun Anda untuk melanjutkan\nsinkronisasi produktivitas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 48),

                _buildTextField(
                  isDark: isDark,
                  controller: _emailController,
                  label: 'Alamat Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  isDark: isDark,
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Lupa Sandi?', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (!isDark) BoxShadow(color: const Color(0xFF1E3A8A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Masuk Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pengguna baru? ', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                      },
                      child: Text('Daftar di sini', style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
        prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey.shade400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E3A8A), width: 2)),
      ),
    );
  }
}
