import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

class SocialLauncher {
  static Future<void> launchFacebook(String value) async {
    final webUri = _facebookWebUri(value);
    if (webUri == null) return;

    final slug = _facebookPageSlug(value);
    final candidates = <Uri>[];

    if (Platform.isAndroid && slug != null) {
      candidates.addAll([
        Uri.parse(
          'intent://www.facebook.com/$slug#Intent;'
          'package=com.facebook.katana;scheme=https;end',
        ),
        Uri.parse(
          'intent://www.facebook.com/$slug#Intent;'
          'package=com.facebook.lite;scheme=https;end',
        ),
      ]);
    }

    if (slug != null) {
      final mobileWeb = Uri.parse('https://m.facebook.com/$slug');
      candidates.add(Uri.parse(
        'fb://facewebmodal/f?href=${Uri.encodeComponent(mobileWeb.toString())}',
      ));
    }

    candidates.add(Uri.parse(
      'fb://facewebmodal/f?href=${Uri.encodeComponent(webUri.toString())}',
    ));
    candidates.add(webUri);

    for (final uri in candidates) {
      if (await _launchUri(uri)) return;
    }
  }

  static Future<void> launchInstagram(String value) async {
    final username = _instagramUsername(value);
    if (username == null || username.isEmpty) return;

    final webUri = _parseSocialUri(value)?.host.contains('instagram.com') == true
        ? _normalizeWebUri(_parseSocialUri(value)!)
        : Uri.parse('https://www.instagram.com/$username/');

    final appUri = Uri.parse('instagram://user?username=$username');

    await _launchAppThenWeb(appUri, webUri);
  }

  static Future<void> launchLinkedin(String value) async {
    final webUri = _linkedinWebUri(value);
    if (webUri == null) return;

    final appUri = _linkedinAppUri(webUri);
    if (appUri != null) {
      await _launchAppThenWeb(appUri, webUri);
    } else {
      await _launchUri(webUri);
    }
  }

  static Future<void> _launchAppThenWeb(Uri appUri, Uri webUri) async {
    if (await _launchUri(appUri)) return;
    await _launchUri(webUri);
  }

  static Future<bool> _launchUri(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Uri? _parseSocialUri(String value) {
    var trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('@')) trimmed = trimmed.substring(1);

    if (trimmed.contains('://')) {
      return Uri.tryParse(trimmed);
    }

    if (trimmed.startsWith('www.') || _looksLikeSocialDomain(trimmed)) {
      return Uri.tryParse('https://$trimmed');
    }

    return null;
  }

  static bool _looksLikeSocialDomain(String value) {
    return RegExp(
      r'^(instagram|facebook|fb|linkedin)\.com',
      caseSensitive: false,
    ).hasMatch(value);
  }

  static Uri _normalizeWebUri(Uri uri) {
    if (uri.scheme == 'http' || uri.scheme == 'https') return uri;
    return uri.replace(scheme: 'https');
  }

  static Uri? _facebookWebUri(String value) {
    final uri = _parseSocialUri(value);
    if (uri != null && _hostContains(uri.host, 'facebook.com')) {
      return _normalizeWebUri(uri);
    }

    final page = _facebookPageSlug(value);
    if (page == null || page.isEmpty) return null;
    return Uri.parse('https://www.facebook.com/$page/');
  }

  static String? _facebookPageSlug(String value) {
    final uri = _parseSocialUri(value);
    if (uri != null && _hostContains(uri.host, 'facebook.com')) {
      final segments =
          uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
      if (segments.isEmpty) return uri.queryParameters['id'];

      if (segments.first == 'profile.php') {
        return uri.queryParameters['id'];
      }

      const reserved = {'pages', 'groups', 'events', 'watch', 'marketplace'};
      if (reserved.contains(segments.first.toLowerCase()) &&
          segments.length > 1) {
        return segments[1];
      }

      return segments.first;
    }

    final handle = _plainHandle(value);
    return handle.isEmpty ? null : handle;
  }

  static String? _instagramUsername(String value) {
    final uri = _parseSocialUri(value);
    if (uri != null && _hostContains(uri.host, 'instagram.com')) {
      final segments =
          uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
      if (segments.isEmpty) return null;

      const reserved = {'p', 'reel', 'reels', 'stories', 'explore', 'tv'};
      if (reserved.contains(segments.first.toLowerCase())) return null;

      return segments.first;
    }

    final handle = _plainHandle(value);
    return handle.isEmpty ? null : handle;
  }

  static Uri? _linkedinWebUri(String value) {
    final uri = _parseSocialUri(value);
    if (uri != null && _hostContains(uri.host, 'linkedin.com')) {
      return _normalizeWebUri(uri);
    }

    final handle = _plainHandle(value);
    if (handle.isEmpty) return null;
    return Uri.parse('https://www.linkedin.com/in/$handle/');
  }

  static Uri? _linkedinAppUri(Uri webUri) {
    final segments =
        webUri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.length < 2) return null;

    final type = segments[0].toLowerCase();
    final slug = segments[1];

    if (type == 'in') {
      return Uri.parse('linkedin://in/$slug');
    }
    if (type == 'company') {
      return Uri.parse('linkedin://company/$slug');
    }

    return null;
  }

  static String _plainHandle(String value) {
    return value.trim().replaceAll('@', '').replaceAll('/', '');
  }

  static bool _hostContains(String host, String domain) {
    return host.toLowerCase().contains(domain);
  }
}
