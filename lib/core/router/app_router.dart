import 'package:go_router/go_router.dart';
import 'package:chatapp/core/router/route_names.dart';
import 'package:chatapp/data/models/chat_group.dart';
import 'package:chatapp/presentation/auth/login_page.dart';
import 'package:chatapp/presentation/home/home_page.dart';
import 'package:chatapp/presentation/chat/chat_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,
  routes: [
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '${RouteNames.chat}/:groupId',
      name: 'chat',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId'] ?? '';
        final group = state.extra as ChatGroup? ?? 
            ChatGroup(id: groupId, name: 'Group', description: '', pin: 0);
        return ChatPage(groupId: groupId, group: group);
      },
    ),
  ],
);
