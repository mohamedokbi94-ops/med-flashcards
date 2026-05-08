import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart';

class UpdateService {
  static const String _repoOwner = 'mohamedokbi94-ops';
  static const String _repoName = 'med-flashcards';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Get current version
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      // Get latest release from GitHub
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
      final releaseNotes = data['body'] as String? ?? '';

      // Find APK download URL
      final assets = data['assets'] as List;
      String? apkUrl;
      for (final asset in assets) {
        if ((asset['name'] as String).endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String;
          break;
        }
      }

      if (apkUrl == null) return;

      // Compare versions
      if (_isNewerVersion(latestVersion, currentVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, releaseNotes, apkUrl);
        }
      }
    } catch (e) {
      // Silently fail — no internet or API error
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    try {
      final l = latest.split('.').map(int.parse).toList();
      final c = current.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final lv = i < l.length ? l[i] : 0;
        final cv = i < c.length ? c[i] : 0;
        if (lv > cv) return true;
        if (lv < cv) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String notes,
    String apkUrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.tealSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.system_update, color: AppTheme.teal, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Mise à jour disponible',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.tealSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Version $version',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.teal)),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Nouveautés :',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(notes,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Mettre à jour'),
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(apkUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}
