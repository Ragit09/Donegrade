import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/toast_util.dart';
import '../../core/services/auth_service.dart';
import '../../main.dart'; // import themeNotifier
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = themeNotifier.value == ThemeMode.dark;
  bool _isNotificationsEnabled = true;
  
  bool _isLoggedIn = false;
  String _name = 'Guest User';
  String _email = 'Tugas Anda hanya disimpan di HP ini';
  File? _localImage;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    final loggedIn = await AuthService.isUserLoggedIn();
    if (loggedIn) {
      final email = await AuthService.getUserEmail();
      final name = await AuthService.getUserName();
      setState(() {
        _isLoggedIn = true;
        _name = name;
        _email = email;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _name = 'Guest User';
        _email = 'Tugas Anda hanya tersimpan di perangkat ini';
      });
    }
  }

  void _showEditProfileDialog() {
    if (!_isLoggedIn) {
      ToastUtil.showTopToast(context, 'Silakan daftar atau masuk untuk mengedit profil.');
      return;
    }

    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newName = nameController.text;
                final newEmail = emailController.text;
                
                // Simpan ke SharedPreferences
                await AuthService.updateProfile(newName, newEmail);
                
                if (!mounted) return;
                setState(() {
                  _name = newName;
                  _email = newEmail;
                });
                Navigator.pop(dialogContext);
                ToastUtil.showTopToast(context, 'Profil berhasil diperbarui!', color: const Color(0xFF10B981));
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePhoto() async {
    if (!_isLoggedIn) {
      ToastUtil.showTopToast(context, 'Silakan daftar atau masuk untuk mengganti foto profil.');
      return;
    }
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _localImage = File(pickedFile.path));
      if (mounted) {
        ToastUtil.showTopToast(context, 'Foto profil berhasil diperbarui!', color: const Color(0xFF10B981));
      }
    }
  }

  void _showSecuritySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('Keamanan & Privasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.password, color: Color(0xFF1E3A8A)),
              title: Text('Ubah Kata Sandi', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user, color: Color(0xFF10B981)),
              title: Text('Autentikasi 2 Langkah', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              trailing: Switch(value: true, activeColor: const Color(0xFF10B981), onChanged: (v){}),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Hapus Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                ToastUtil.showTopToast(context, 'Permintaan penghapusan akun diproses.', color: Colors.red);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureOld = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (dialogBuilderContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Lama',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext); // Tutup dialog ubah sandi menggunakan context dari dialog
                        ToastUtil.showTopToast(context, 'Sedang memverifikasi dengan Google...'); // Tampilkan toast dengan context halaman utama
                        final errorMsg = await AuthService.resetPassword(_email);
                        
                        if (!mounted) return;
                        
                        if (errorMsg != null) {
                          ToastUtil.showTopToast(context, errorMsg, color: Colors.redAccent);
                        } else {
                          ToastUtil.showTopToast(context, 'Verifikasi berhasil! Tautan reset telah dikirim ke $_email.', color: const Color(0xFF10B981));
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Lupa Kata Sandi?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
                      ToastUtil.showTopToast(context, 'Kolom tidak boleh kosong!', color: Colors.redAccent);
                      return;
                    }
                    setDialogState(() => isLoading = true);
                    
                    final errorMsg = await AuthService.changePassword(
                      _email, 
                      oldPasswordController.text, 
                      newPasswordController.text,
                    );
                    
                    if (!mounted) return;
                    
                    if (errorMsg != null) {
                      setDialogState(() => isLoading = false);
                      ToastUtil.showTopToast(context, errorMsg, color: Colors.redAccent);
                    } else {
                      Navigator.pop(dialogContext);
                      ToastUtil.showTopToast(context, 'Kata sandi berhasil diubah!', color: const Color(0xFF10B981));
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog
                await AuthService.logout();
                if (!mounted) return;
                setState(() { _localImage = null; });
                ToastUtil.showTopToast(context, 'Berhasil keluar akun.', color: Colors.green);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            title: Text('Profil', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
            centerTitle: false,
            actions: [
              if (_isLoggedIn)
                IconButton(
                  icon: Icon(Icons.edit_note_rounded, size: 28, color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
                  onPressed: _showEditProfileDialog,
                  tooltip: 'Edit Profil',
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Guest Banner
                  if (!_isLoggedIn)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF1E3A8A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Simpan Data Anda!',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tugas Anda saat ini hanya tersimpan di perangkat ini. Daftar sekarang untuk mengaktifkan sinkronisasi ke awan.',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1E3A8A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                              },
                              child: const Text('Daftar / Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Profile Info
                  GestureDetector(
                    onTap: _changePhoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: _isLoggedIn ? const Color(0xFF1E3A8A).withOpacity(0.1) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!) as ImageProvider
                              : (_isLoggedIn
                                  ? NetworkImage('https://ui-avatars.com/api/?name=${_name.replaceAll(' ', '+')}&background=1E3A8A&color=fff&size=128')
                                  : null),
                          child: !_isLoggedIn ? Icon(Icons.person, size: 50, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400) : null,
                        ),
                        if (_isLoggedIn)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 14, color: _isLoggedIn ? Colors.grey.shade500 : Colors.orange.shade600, fontWeight: _isLoggedIn ? FontWeight.normal : FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Settings Options
                  _buildSectionHeader('PENGATURAN UMUM'),
                  _buildListTile(
                    isDark: isDark,
                    icon: Icons.dark_mode_outlined,
                    title: 'Mode Gelap (Dark Mode)',
                    trailing: Switch(
                      value: _isDarkMode,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        setState(() => _isDarkMode = val);
                        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),
                  _buildListTile(
                    isDark: isDark,
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifikasi',
                    trailing: Switch(
                      value: _isNotificationsEnabled,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        setState(() => _isNotificationsEnabled = val);
                        ToastUtil.showTopToast(context, val ? 'Notifikasi diaktifkan.' : 'Notifikasi dimatikan.');
                      },
                    ),
                  ),
                  
                  if (_isLoggedIn) ...[
                    const SizedBox(height: 16),
                    _buildSectionHeader('AKUN & DATA'),
                    _buildListTile(
                      isDark: isDark,
                      icon: Icons.cloud_sync_outlined,
                      title: 'Sinkronisasi Firebase',
                      subtitle: 'Otomatis tersimpan ke awan',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ToastUtil.showTopToast(context, 'Semua tugas telah disinkronkan ke server!', color: const Color(0xFF10B981));
                      },
                    ),
                    _buildListTile(
                      isDark: isDark,
                      icon: Icons.security_outlined,
                      title: 'Keamanan & Privasi',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showSecuritySettings,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutConfirmationDialog,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text('Keluar Akun', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildListTile({required bool isDark, required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A)),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B))),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)) : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
