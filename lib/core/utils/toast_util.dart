import 'package:flutter/material.dart';

class ToastUtil {
  static void showTopToast(BuildContext context, String message, {Color color = const Color(0xFF1E3A8A)}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    
    // Ambil padding top sebelum masuk ke OverlayEntry context untuk menghindari error MediaQuery
    final topPadding = MediaQuery.of(context).padding.top;
    
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 20,
        left: 24.0,
        right: 24.0,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            // Harus spesifik <double> agar tidak terjadi error Type di Flutter
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
