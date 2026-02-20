import 'package:go_router/go_router.dart';
import 'package:chatapp/presentation/auth/login_page.dart';
import 'package:chatapp/presentation/home/home_page.dart'; // Sesuaikan path impor milikmu

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
  ],
);