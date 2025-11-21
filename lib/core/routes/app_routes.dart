import 'package:flutter/material.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/webview/presentation/pages/webview_page.dart';
import 'route_transitions.dart';

class AppRoutes {
  static const String login = '/login';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String webview = '/webview';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return SlideToRightRoute(builder: (_) => const LoginPage());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      
      case AppRoutes.settings:
        return SlideFromRightRoute(builder: (_) => const SettingsPage());
      
      case webview:
        final url = settings.arguments as String? ?? '';
        return BottomSheetRoute(
          builder: (_) => WebViewPage(url: url),
        );
      
      default:
        return SlideToRightRoute(builder: (_) => const LoginPage());
    }
  }
}

