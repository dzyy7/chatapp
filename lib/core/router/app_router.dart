import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatapp/core/router/route_names.dart';
import 'package:chatapp/presentation/splash/splash_page.dart';
import 'package:chatapp/presentation/intro/intro_page.dart';
import 'package:chatapp/presentation/auth/login_page.dart';
import 'package:chatapp/presentation/auth/register_page.dart';
import 'package:chatapp/presentation/home/home_page.dart';
import 'package:chatapp/presentation/chat/chat_page.dart';
import 'package:chatapp/presentation/contacts/contacts_page.dart';
import 'package:chatapp/presentation/profile/profile_page.dart';
import 'package:chatapp/presentation/settings/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.intro,
        name: 'intro',
        builder: (context, state) => const IntroPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.chat,
        name: 'chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatPage(
            conversationId: extra?['conversationId'] ?? '',
            contactName: extra?['contactName'] ?? '',
            contactAvatar: extra?['contactAvatar'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.contacts,
        name: 'contacts',
        builder: (context, state) => const ContactsPage(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
