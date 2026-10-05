import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Handles both uploaded URLs and the embedded photos saved by onboarding.
class ProfilePhoto extends StatelessWidget {
  final String? url;
  final String name;

  const ProfilePhoto({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final source = url?.trim() ?? '';
    Widget fallback() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.darkSurface],
        ),
      ),
      alignment: const Alignment(0, -0.25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              name.trim().isEmpty
                  ? '?'
                  : name.trim().characters.first.toUpperCase(),
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Photo unavailable',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    final uri = Uri.tryParse(source);
    final data = uri?.data;
    if (data != null && data.mimeType.startsWith('image/')) {
      try {
        return Image.memory(
          data.contentAsBytes(),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          semanticLabel: 'Photo of $name',
          errorBuilder: (_, error, stack) => fallback(),
        );
      } on FormatException {
        return fallback();
      }
    }
    if (uri == null ||
        !['https', 'http'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return fallback();
    }
    return Image.network(
      source,
      fit: BoxFit.cover,
      semanticLabel: 'Photo of $name',
      // Allows cross-origin portraits on web when the host omits CORS headers.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.darkSurface,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
      errorBuilder: (_, error, stack) => fallback(),
    );
  }
}
